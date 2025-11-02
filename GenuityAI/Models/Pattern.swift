//
//  Pattern.swift
//  Genuity AI
//
//  Pattern detection and prediction models
//

import Foundation

// MARK: - Detected Pattern

struct DetectedPattern: Identifiable, Codable {
    let id: UUID
    let type: PatternType
    let trigger: String          // "Monday", "poor sleep", "no exercise"
    let impact: Double           // How much it affects mood (-2.0 to +2.0)
    let confidence: Double       // 0.0 to 1.0 (how sure we are)
    let sampleSize: Int          // How many data points
    let description: String      // Human-readable explanation
    
    init(type: PatternType, trigger: String, impact: Double, confidence: Double, sampleSize: Int, description: String) {
        self.id = UUID()
        self.type = type
        self.trigger = trigger
        self.impact = impact
        self.confidence = confidence
        self.sampleSize = sampleSize
        self.description = description
    }
}

enum PatternType: String, Codable {
    case dayOfWeek
    case timeOfDay
    case activity
    case sleep
    case social
    case weather
    case custom
}

// MARK: - Mood Prediction

struct MoodPrediction: Identifiable, Codable {
    let id: UUID
    let date: Date
    let predictedMood: Double      // 1.0 - 5.0
    let riskLevel: RiskLevel
    let riskFactors: [RiskFactor]
    let interventionPlan: InterventionPlan?
    let createdAt: Date
    
    init(date: Date, predictedMood: Double, riskFactors: [RiskFactor], interventionPlan: InterventionPlan? = nil) {
        self.id = UUID()
        self.date = date
        self.predictedMood = predictedMood
        self.riskLevel = {
            if predictedMood < 2.5 { return .high }
            else if predictedMood < 3.5 { return .medium }
            else { return .low }
        }()
        self.riskFactors = riskFactors
        self.interventionPlan = interventionPlan
        self.createdAt = Date()
    }
}

enum RiskLevel: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var emoji: String {
        switch self {
        case .low: return "✅"
        case .medium: return "⚠️"
        case .high: return "🚨"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

struct RiskFactor: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String               // "Monday mornings"
    let impact: Double             // -1.2
    let confidence: Double         // 0.85
    let source: String             // "Historical pattern"
    
    init(name: String, impact: Double, confidence: Double, source: String = "Pattern analysis") {
        self.id = UUID()
        self.name = name
        self.impact = impact
        self.confidence = confidence
        self.source = source
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RiskFactor, rhs: RiskFactor) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Intervention Plan

struct InterventionPlan: Codable {
    let steps: [InterventionStep]
    let predictedImprovement: Double  // How much mood should improve
    let generatedBy: String           // "AI" or "Template"
    let createdAt: Date
    
    init(steps: [InterventionStep], predictedImprovement: Double, generatedBy: String = "AI") {
        self.steps = steps
        self.predictedImprovement = predictedImprovement
        self.generatedBy = generatedBy
        self.createdAt = Date()
    }
}

struct InterventionStep: Identifiable, Codable {
    let id: UUID
    let timing: String             // "Tonight", "Tomorrow morning"
    let action: String             // "Go to bed by 10 PM"
    let reason: String             // "Sleep boosts mood by +1.2"
    let reminderTime: Date?        // When to remind
    
    init(timing: String, action: String, reason: String, reminderTime: Date? = nil) {
        self.id = UUID()
        self.timing = timing
        self.action = action
        self.reason = reason
        self.reminderTime = reminderTime
    }
}

// MARK: - Prediction Result (Effectiveness Tracking)

struct PredictionResult: Identifiable, Codable {
    let id: UUID
    let predictionDate: Date
    let predictedMood: Double
    let actualMood: Double
    let accuracy: Double           // 0.0 to 1.0
    let interventionUsed: Bool
    let improvement: Double?       // If intervention was used
    
    init(predictionDate: Date, predictedMood: Double, actualMood: Double, interventionUsed: Bool = false) {
        self.id = UUID()
        self.predictionDate = predictionDate
        self.predictedMood = predictedMood
        self.actualMood = actualMood
        self.accuracy = 1.0 - abs(predictedMood - actualMood) / 5.0
        self.interventionUsed = interventionUsed
        self.improvement = interventionUsed ? (actualMood - predictedMood) : nil
    }
}

