//
//  DataManager.swift
//  Genuity AI
//
//  Data persistence and management
//

import Foundation
import SwiftUI

@MainActor
class DataManager: ObservableObject {
    @Published var entries: [MoodEntry] = []
    @Published var accountabilityChecks: [AccountabilityCheck] = []
    @Published var effectivenessReports: [EffectivenessReport] = []
    
    private let entriesKey = "GenuityAI_MoodEntries"
    private let accountabilityKey = "GenuityAI_AccountabilityChecks"
    private let effectivenessKey = "GenuityAI_EffectivenessReports"
    
    init() {
        loadEntries()
        loadAccountabilityChecks()
        loadEffectivenessReports()
    }
    
    // MARK: - CRUD Operations
    
    func addEntry(_ entry: MoodEntry) {
        entries.insert(entry, at: 0) // Most recent first
        saveEntries()
    }
    
    func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }
    
    func deleteEntry(_ entry: MoodEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    // MARK: - Data Queries
    
    func recentEntries(days: Int) -> [MoodEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return entries
            .filter { $0.timestamp >= cutoffDate }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    func averageMood(days: Int) -> Double {
        let recent = recentEntries(days: days)
        guard !recent.isEmpty else { return 0 }
        let sum = recent.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(recent.count)
    }
    
    func moodTrend(days: Int) -> String {
        let recent = recentEntries(days: days)
        guard recent.count >= 2 else { return "neutral" }
        
        let halfCount = recent.count / 2
        let firstHalf = recent.prefix(halfCount)
        let secondHalf = recent.suffix(halfCount)
        
        let firstAvg = Double(firstHalf.reduce(0) { $0 + $1.moodScore }) / Double(firstHalf.count)
        let secondAvg = Double(secondHalf.reduce(0) { $0 + $1.moodScore }) / Double(secondHalf.count)
        
        if secondAvg > firstAvg + 0.5 {
            return "improving"
        } else if secondAvg < firstAvg - 0.5 {
            return "declining"
        } else {
            return "stable"
        }
    }
    
    // MARK: - Secure Persistence (Keychain)
    
    private func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            
            // Save to secure Keychain (encrypted by iOS)
            let success = KeychainManager.shared.save(data: data, forKey: entriesKey)
            
            if success {
                print("✓ Mood data securely encrypted and saved")
            } else {
                // Fallback to UserDefaults for development
                #if DEBUG
                UserDefaults.standard.set(data, forKey: entriesKey)
                print("⚠️ Saved to UserDefaults (dev mode)")
                #endif
            }
        } catch {
            print("Error saving entries: \(error.localizedDescription)")
        }
    }
    
    private func loadEntries() {
        // Try to load from secure Keychain first
        if let data = KeychainManager.shared.load(forKey: entriesKey) {
            do {
                entries = try JSONDecoder().decode([MoodEntry].self, from: data)
                print("✓ Loaded \(entries.count) entries from secure Keychain")
                return
            } catch {
                print("Error decoding from Keychain: \(error.localizedDescription)")
            }
        }
        
        // Fallback: Try UserDefaults (migration or dev mode)
        if let data = UserDefaults.standard.data(forKey: entriesKey) {
            do {
                entries = try JSONDecoder().decode([MoodEntry].self, from: data)
                print("✓ Loaded from UserDefaults, migrating to Keychain...")
                saveEntries() // Migrate to Keychain
                UserDefaults.standard.removeObject(forKey: entriesKey)
                return
            } catch {
                print("Error loading entries: \(error.localizedDescription)")
            }
        }
        
        // No data found - load sample data for preview/testing
        #if DEBUG
        entries = MoodEntry.predictiveSampleData
        print("✓ Loaded demo data (14 entries)")
        #endif
    }
    
    // MARK: - Demo Data
    
    func loadPredictiveDemoData() {
        entries = MoodEntry.predictiveSampleData
        saveEntries()
    }
    
    // MARK: - Export/Import
    
    func exportData() -> String {
        guard let data = try? JSONEncoder().encode(entries),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return jsonString
    }
    
    func importData(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8),
              let imported = try? JSONDecoder().decode([MoodEntry].self, from: data) else {
            return false
        }
        entries = imported
        saveEntries()
        return true
    }
    
    // Clear all data
    func clearAllData() {
        entries = []
        accountabilityChecks = []
        effectivenessReports = []
        UserDefaults.standard.removeObject(forKey: entriesKey)
        UserDefaults.standard.removeObject(forKey: accountabilityKey)
        UserDefaults.standard.removeObject(forKey: effectivenessKey)
    }
    
    // MARK: - Accountability Management
    
    func addAccountabilityCheck(_ check: AccountabilityCheck) {
        accountabilityChecks.append(check)
        saveAccountabilityChecks()
    }
    
    func updateAccountabilityCheck(_ check: AccountabilityCheck) {
        if let index = accountabilityChecks.firstIndex(where: { $0.id == check.id }) {
            accountabilityChecks[index] = check
            saveAccountabilityChecks()
            
            // Generate effectiveness report if completed
            if check.completed, let actualMood = check.actualMood {
                generateEffectivenessReport(from: check, actualMood: actualMood)
            }
        }
    }
    
    private func generateEffectivenessReport(from check: AccountabilityCheck, actualMood: Int) {
        let stepsCompleted = check.actualFollowThrough.filter { $0.completed }.count
        let totalSteps = check.actualFollowThrough.count
        
        // Default predicted mood
        let predictedMood = 2.5
        
        let report = EffectivenessReport(
            date: check.scheduledDate,
            predictedMood: predictedMood,
            actualMood: Double(actualMood),
            interventionUsed: stepsCompleted > 0,
            stepsCompleted: stepsCompleted,
            totalSteps: totalSteps
        )
        
        effectivenessReports.append(report)
        saveEffectivenessReports()
    }
    
    private func saveAccountabilityChecks() {
        if let data = try? JSONEncoder().encode(accountabilityChecks) {
            UserDefaults.standard.set(data, forKey: accountabilityKey)
        }
    }
    
    private func loadAccountabilityChecks() {
        if let data = UserDefaults.standard.data(forKey: accountabilityKey),
           let checks = try? JSONDecoder().decode([AccountabilityCheck].self, from: data) {
            accountabilityChecks = checks
        }
    }
    
    private func saveEffectivenessReports() {
        if let data = try? JSONEncoder().encode(effectivenessReports) {
            UserDefaults.standard.set(data, forKey: effectivenessKey)
        }
    }
    
    private func loadEffectivenessReports() {
        if let data = UserDefaults.standard.data(forKey: effectivenessKey),
           let reports = try? JSONDecoder().decode([EffectivenessReport].self, from: data) {
            effectivenessReports = reports
        }
    }
}

