//
//  AccountabilityCheck.swift
//  Genuity AI
//
//  Follow-up system to ensure prevention plans are followed
//

import Foundation

struct AccountabilityCheck: Identifiable, Codable {
    let id: UUID
    let predictionId: UUID
    let interventionPlan: InterventionPlan
    let scheduledDate: Date
    var completed: Bool
    var actualFollowThrough: [StepCompletion]
    var actualMood: Int?
    
    init(predictionId: UUID, interventionPlan: InterventionPlan, scheduledDate: Date) {
        self.id = UUID()
        self.predictionId = predictionId
        self.interventionPlan = interventionPlan
        self.scheduledDate = scheduledDate
        self.completed = false
        self.actualFollowThrough = interventionPlan.steps.map { step in
            StepCompletion(stepId: step.id, completed: false, notes: nil)
        }
        self.actualMood = nil
    }
}

struct StepCompletion: Codable {
    let stepId: UUID
    var completed: Bool
    var notes: String?
}

// MARK: - Effectiveness Report

struct EffectivenessReport: Identifiable, Codable {
    let id: UUID
    let date: Date
    let predictedMood: Double
    let actualMood: Double
    let interventionUsed: Bool
    let stepsCompleted: Int
    let totalSteps: Int
    
    init(id: UUID = UUID(), date: Date, predictedMood: Double, actualMood: Double, interventionUsed: Bool, stepsCompleted: Int, totalSteps: Int) {
        self.id = id
        self.date = date
        self.predictedMood = predictedMood
        self.actualMood = actualMood
        self.interventionUsed = interventionUsed
        self.stepsCompleted = stepsCompleted
        self.totalSteps = totalSteps
    }
    
    var accuracy: Double {
        1.0 - abs(predictedMood - actualMood) / 5.0
    }
    
    var improvement: Double? {
        guard interventionUsed else { return nil }
        return actualMood - predictedMood
    }
    
    var complianceRate: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(stepsCompleted) / Double(totalSteps)
    }
    
    var wasEffective: Bool {
        guard let improvement = improvement else { return false }
        return improvement > 0.5
    }
}

