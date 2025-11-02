//
//  HealthKitManager.swift
//  Genuity AI
//
//  Sleep and exercise data from Apple Health
//

import Foundation
import HealthKit

@MainActor
class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    @Published var lastNightSleep: Double?
    @Published var todaySteps: Int?
    @Published var todayExerciseMinutes: Int?
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available")
            return false
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            isAuthorized = true
            print("✓ HealthKit authorized")
            return true
        } catch {
            print("HealthKit authorization failed: \(error)")
            return false
        }
    }
    
    // MARK: - Sleep Data
    
    func fetchLastNightSleep() async -> Double? {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: startOfToday, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Calculate total sleep time in hours
                let totalSleep = samples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue || 
                              $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                
                let hours = totalSleep / 3600.0
                continuation.resume(returning: hours > 0 ? hours : nil)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Exercise Data
    
    func fetchTodayExercise() async -> Int? {
        let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let sum = result.sumQuantity(), error == nil else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let minutes = Int(sum.doubleValue(for: HKUnit.minute()))
                continuation.resume(returning: minutes)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Steps Data
    
    func fetchTodaySteps() async -> Int? {
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                guard let result = result, let sum = result.sumQuantity(), error == nil else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Convenience Method
    
    func fetchAllTodayData() async -> HealthData {
        async let sleep = fetchLastNightSleep()
        async let steps = fetchTodaySteps()
        async let exercise = fetchTodayExercise()
        
        return await HealthData(
            sleepHours: sleep,
            steps: steps,
            exerciseMinutes: exercise
        )
    }
}

struct HealthData {
    let sleepHours: Double?
    let steps: Int?
    let exerciseMinutes: Int?
    
    var sleepQuality: String {
        guard let hours = sleepHours else { return "Unknown" }
        if hours >= 8 { return "Excellent" }
        if hours >= 7 { return "Good" }
        if hours >= 6 { return "Fair" }
        return "Poor"
    }
    
    var hasExercised: Bool {
        (exerciseMinutes ?? 0) >= 10
    }
    
    var isActive: Bool {
        (steps ?? 0) >= 5000
    }
}

