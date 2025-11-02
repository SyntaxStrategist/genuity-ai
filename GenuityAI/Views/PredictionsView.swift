//
//  PredictionsView.swift
//  Genuity AI
//
//  Predictive mood alerts and intervention plans
//

import SwiftUI

struct PredictionsView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var patternEngine = PatternEngine()
    @State private var showingInterventionPlan = false
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if dataManager.entries.count < 7 {
                        lockedStateView
                    } else {
                        if let prediction = patternEngine.currentPrediction {
                            predictionCard(prediction)
                            
                            if let plan = prediction.interventionPlan {
                                interventionPlanCard(plan)
                            }
                        } else {
                            noPredictionView
                        }
                        
                        detectedPatternsCard
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Predictions")
            .background(Color(.systemGroupedBackground))
            .task {
                if dataManager.entries.count >= 7 {
                    await analyzePredictions()
                }
            }
            .refreshable {
                await analyzePredictions()
            }
        }
    }
    
    private var lockedStateView: some View {
        LockedPredictionsContent(entryCount: dataManager.entries.count)
    }
    
    private var noPredictionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("✅ All Good!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("No concerning patterns detected for tomorrow.\nYour mood should be stable.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Text("I'll alert you if I detect any risks")
                .font(.caption)
                .foregroundColor(.purple)
        }
        .padding()
    }
    
    private func predictionCard(_ prediction: MoodPrediction) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tomorrow's Prediction")
                        .font(.headline)
                    Text(prediction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text(String(format: "%.1f", prediction.predictedMood))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(riskColor(prediction.riskLevel))
                    Text(prediction.riskLevel.emoji + " " + prediction.riskLevel.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !prediction.riskFactors.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Risk Factors:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(prediction.riskFactors) { factor in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(factor.name)
                                    .font(.subheadline)
                                Text(factor.source)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(String(format: "%.1f", factor.impact))
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10)
        .padding(.horizontal)
    }
    
    private func interventionPlanCard(_ plan: InterventionPlan) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("🎯 Prevention Plan", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundColor(.purple)
            
            Text("Follow these steps to improve your predicted mood by \(String(format: "%.1f", plan.predictedImprovement)) points")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                ForEach(Array(plan.steps.enumerated()), id: \.element.id) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.purple)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.timing)
                                .font(.caption)
                                .foregroundColor(.purple)
                                .fontWeight(.semibold)
                            
                            Text(step.action)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(step.reason)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if index < plan.steps.count - 1 {
                        Divider()
                    }
                }
            }
            
            Button(action: {
                // Schedule reminders for each step
                scheduleInterventionReminders(plan)
            }) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                    Text("Set Reminders for All Steps")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    private var detectedPatternsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Detected Patterns", systemImage: "brain.head.profile")
                .font(.headline)
            
            if patternEngine.detectedPatterns.isEmpty {
                Text("Analyzing your data for patterns...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(patternEngine.detectedPatterns.prefix(5)) { pattern in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pattern.description)
                                    .font(.subheadline)
                                
                                Text("\(pattern.sampleSize) data points • \(Int(pattern.confidence * 100))% confidence")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: pattern.impact > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(pattern.impact > 0 ? .green : .red)
                        }
                        .padding()
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    private func analyzePredictions() async {
        isAnalyzing = true
        
        // Detect patterns
        let patterns = patternEngine.detectPatterns(from: dataManager.entries)
        
        // Generate prediction for tomorrow
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        if let prediction = patternEngine.generatePrediction(for: tomorrow, entries: dataManager.entries, patterns: patterns) {
            
            // Generate intervention plan if high/medium risk
            if prediction.riskLevel != .low {
                do {
                    let plan = try await patternEngine.generateInterventionPlan(for: prediction, userPatterns: patterns)
                    patternEngine.currentPrediction = MoodPrediction(
                        date: prediction.date,
                        predictedMood: prediction.predictedMood,
                        riskFactors: prediction.riskFactors,
                        interventionPlan: plan
                    )
                    
                    // Schedule notification
                    NotificationManager.shared.schedulePredictiveAlert(prediction: patternEngine.currentPrediction!)
                } catch {
                    print("Failed to generate intervention: \(error)")
                    patternEngine.currentPrediction = prediction
                }
            } else {
                patternEngine.currentPrediction = nil
            }
        } else {
            patternEngine.currentPrediction = nil
        }
        
        isAnalyzing = false
    }
    
    private func scheduleInterventionReminders(_ plan: InterventionPlan) {
        for step in plan.steps {
            if let reminderTime = step.reminderTime {
                NotificationManager.shared.scheduleInterventionReminder(
                    at: reminderTime,
                    title: step.timing,
                    body: step.action
                )
            }
        }
    }
    
    private func riskColor(_ level: RiskLevel) -> Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct LockedPredictionsContent: View {
    let entryCount: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "crystal.ball")
                .font(.system(size: 80))
                .foregroundStyle(.purple.gradient)
                .padding()
            
            Text("🔮 Predictions Locked")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("I need 7 days of data to start predicting your mood patterns.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Progress
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(0..<7) { day in
                        Circle()
                            .fill(day < entryCount ? Color.purple : Color.gray.opacity(0.3))
                            .frame(width: 35, height: 35)
                            .overlay(
                                Group {
                                    if day < entryCount {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    } else {
                                        Text("\(day + 1)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                    }
                }
                
                Text("\(entryCount) of 7 days completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    PredictionsView()
        .environmentObject(DataManager())
}

