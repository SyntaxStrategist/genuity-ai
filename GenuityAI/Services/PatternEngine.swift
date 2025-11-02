//
//  PatternEngine.swift
//  Genuity AI
//
//  Pattern detection and prediction engine
//

import Foundation

@MainActor
class PatternEngine: ObservableObject {
    @Published var detectedPatterns: [DetectedPattern] = []
    @Published var currentPrediction: MoodPrediction?
    
    // MARK: - Pattern Detection
    
    func detectPatterns(from entries: [MoodEntry]) -> [DetectedPattern] {
        guard entries.count >= 7 else { return [] }
        
        var patterns: [DetectedPattern] = []
        
        // 1. Sleep Patterns (MOST IMPORTANT!)
        patterns.append(contentsOf: detectSleepPatterns(entries))
        
        // 2. Exercise Patterns
        patterns.append(contentsOf: detectExercisePatterns(entries))
        
        // 3. Activity Patterns
        patterns.append(contentsOf: detectActivityPatterns(entries))
        
        // 4. Day of Week Patterns
        patterns.append(contentsOf: detectDayOfWeekPatterns(entries))
        
        // 5. Time of Day Patterns
        patterns.append(contentsOf: detectTimeOfDayPatterns(entries))
        
        detectedPatterns = patterns
        return patterns
    }
    
    // MARK: - Day of Week Analysis
    
    private func detectDayOfWeekPatterns(_ entries: [MoodEntry]) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        let overallAvg = average(entries.map { Double($0.moodScore) })
        
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        
        for day in weekdays {
            let dayEntries = entries.filter { 
                Calendar.current.component(.weekday, from: $0.timestamp) == weekdayNumber(for: day)
            }
            
            guard dayEntries.count >= 2 else { continue }
            
            let dayAvg = average(dayEntries.map { Double($0.moodScore) })
            let impact = dayAvg - overallAvg
            
            // Only flag significant patterns
            if abs(impact) > 0.5 {
                let confidence = min(0.95, Double(dayEntries.count) / 10.0)
                
                // Create sensible description
                let description: String
                if impact > 0 {
                    description = "\(day)s are your best day (\(String(format: "%.1f", dayAvg))/5 vs \(String(format: "%.1f", overallAvg))/5 avg)"
                } else {
                    description = "\(day)s are challenging for you (\(String(format: "%.1f", dayAvg))/5 vs \(String(format: "%.1f", overallAvg))/5 avg)"
                }
                
                patterns.append(DetectedPattern(
                    type: .dayOfWeek,
                    trigger: day,
                    impact: impact,
                    confidence: confidence,
                    sampleSize: dayEntries.count,
                    description: description
                ))
            }
        }
        
        return patterns
    }
    
    // MARK: - Sleep Pattern Analysis (GAME CHANGER!)
    
    private func detectSleepPatterns(_ entries: [MoodEntry]) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        let entriesWithSleep = entries.filter { $0.sleepHours != nil }
        guard entriesWithSleep.count >= 5 else { return patterns }
        
        let goodSleep = entriesWithSleep.filter { ($0.sleepHours ?? 0) >= 7.5 }
        let poorSleep = entriesWithSleep.filter { ($0.sleepHours ?? 0) < 6.5 }
        
        if goodSleep.count >= 2 && poorSleep.count >= 2 {
            let goodAvg = average(goodSleep.map { Double($0.moodScore) })
            let poorAvg = average(poorSleep.map { Double($0.moodScore) })
            let impact = goodAvg - poorAvg
            
            if abs(impact) > 0.5 {
                patterns.append(DetectedPattern(
                    type: .sleep,
                    trigger: "Sleep Quality",
                    impact: impact,
                    confidence: 0.90,
                    sampleSize: goodSleep.count + poorSleep.count,
                    description: impact > 0 
                        ? "💤 8+ hours sleep → \(String(format: "%.1f", goodAvg))/5 mood vs <7h → \(String(format: "%.1f", poorAvg))/5 (\(String(format: "+%.1f", impact)) boost)"
                        : "💤 Poor sleep (<7h) drops your mood by \(String(format: "%.1f", abs(impact))) points"
                ))
            }
        }
        
        return patterns
    }
    
    // MARK: - Exercise Pattern Analysis
    
    private func detectExercisePatterns(_ entries: [MoodEntry]) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        let entriesWithData = entries.filter { $0.exerciseMinutes != nil }
        guard entriesWithData.count >= 5 else { return patterns }
        
        let exercised = entriesWithData.filter { ($0.exerciseMinutes ?? 0) >= 20 }
        let noExercise = entriesWithData.filter { ($0.exerciseMinutes ?? 0) < 20 }
        
        if exercised.count >= 2 && noExercise.count >= 2 {
            let exerciseAvg = average(exercised.map { Double($0.moodScore) })
            let noExerciseAvg = average(noExercise.map { Double($0.moodScore) })
            let impact = exerciseAvg - noExerciseAvg
            
            if abs(impact) > 0.5 {
                patterns.append(DetectedPattern(
                    type: .activity,
                    trigger: "Exercise",
                    impact: impact,
                    confidence: 0.92,
                    sampleSize: exercised.count + noExercise.count,
                    description: "🏃 Exercise (20+ min) → \(String(format: "%.1f", exerciseAvg))/5 vs no exercise → \(String(format: "%.1f", noExerciseAvg))/5 (\(String(format: "+%.1f", impact)) boost!)"
                ))
            }
        }
        
        return patterns
    }
    
    // MARK: - Activity Pattern Analysis
    
    private func detectActivityPatterns(_ entries: [MoodEntry]) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        // Group by activity
        var activityMoods: [String: [Int]] = [:]
        for entry in entries {
            for activity in entry.activities {
                activityMoods[activity, default: []].append(entry.moodScore)
            }
        }
        
        let overallAvg = average(entries.map { Double($0.moodScore) })
        
        for (activity, moods) in activityMoods where moods.count >= 3 {
            let activityAvg = average(moods.map { Double($0) })
            let impact = activityAvg - overallAvg
            
            if abs(impact) > 0.3 {
                let confidence = min(0.95, Double(moods.count) / 15.0)
                
                // Create clear description with actual scores
                let description: String
                if impact > 0 {
                    description = "\(activity) boosts your mood (\(String(format: "%.1f", activityAvg))/5 with vs \(String(format: "%.1f", overallAvg))/5 without)"
                } else {
                    description = "\(activity) correlates with lower mood (\(String(format: "%.1f", activityAvg))/5 vs \(String(format: "%.1f", overallAvg))/5 avg)"
                }
                
                patterns.append(DetectedPattern(
                    type: .activity,
                    trigger: activity,
                    impact: impact,
                    confidence: confidence,
                    sampleSize: moods.count,
                    description: description
                ))
            }
        }
        
        return patterns.sorted { abs($0.impact) > abs($1.impact) }
    }
    
    // MARK: - Time of Day Analysis
    
    private func detectTimeOfDayPatterns(_ entries: [MoodEntry]) -> [DetectedPattern] {
        var patterns: [DetectedPattern] = []
        
        let morningEntries = entries.filter { Calendar.current.component(.hour, from: $0.timestamp) < 12 }
        let afternoonEntries = entries.filter { 
            let hour = Calendar.current.component(.hour, from: $0.timestamp)
            return hour >= 12 && hour < 18
        }
        let eveningEntries = entries.filter { Calendar.current.component(.hour, from: $0.timestamp) >= 18 }
        
        guard morningEntries.count >= 2, afternoonEntries.count >= 2 || eveningEntries.count >= 2 else {
            return patterns
        }
        
        let morningAvg = average(morningEntries.map { Double($0.moodScore) })
        let afternoonAvg = afternoonEntries.isEmpty ? 0 : average(afternoonEntries.map { Double($0.moodScore) })
        let eveningAvg = eveningEntries.isEmpty ? 0 : average(eveningEntries.map { Double($0.moodScore) })
        
        let overallAvg = average(entries.map { Double($0.moodScore) })
        
        if abs(morningAvg - overallAvg) > 0.5 {
            patterns.append(DetectedPattern(
                type: .timeOfDay,
                trigger: "Morning",
                impact: morningAvg - overallAvg,
                confidence: 0.75,
                sampleSize: morningEntries.count,
                description: morningAvg > overallAvg 
                    ? "You're a morning person - your mood is highest before noon"
                    : "Mornings are tough for you - consider evening activities instead"
            ))
        }
        
        return patterns
    }
    
    // MARK: - Prediction Generation
    
    func generatePrediction(for date: Date, entries: [MoodEntry], patterns: [DetectedPattern]) -> MoodPrediction? {
        guard entries.count >= 7 else { return nil }
        
        let overallAvg = average(entries.map { Double($0.moodScore) })
        var predictedMood = overallAvg
        var riskFactors: [RiskFactor] = []
        
        // Check day of week pattern
        let weekday = Calendar.current.component(.weekday, from: date)
        let dayName = Calendar.current.weekdaySymbols[weekday - 1]
        
        if let dayPattern = patterns.first(where: { $0.type == .dayOfWeek && $0.trigger == dayName }) {
            predictedMood += dayPattern.impact
            
            if dayPattern.impact < -0.5 {
                riskFactors.append(RiskFactor(
                    name: "\(dayName)s are typically challenging for you",
                    impact: dayPattern.impact,
                    confidence: dayPattern.confidence,
                    source: "Based on \(dayPattern.sampleSize) past \(dayName)s"
                ))
            }
        }
        
        // TODO: Add sleep, calendar, weather factors when integrated
        
        guard !riskFactors.isEmpty || predictedMood < 3.5 else {
            return nil // Don't alert for good predicted days
        }
        
        return MoodPrediction(
            date: date,
            predictedMood: max(1.0, min(5.0, predictedMood)),
            riskFactors: riskFactors
        )
    }
    
    // MARK: - Intervention Plan Generation
    
    func generateInterventionPlan(for prediction: MoodPrediction, userPatterns: [DetectedPattern]) async throws -> InterventionPlan {
        // Find what helps this user
        let positiveActivities = userPatterns
            .filter { $0.type == .activity && $0.impact > 0.5 }
            .sorted { $0.impact > $1.impact }
        
        var steps: [InterventionStep] = []
        
        // Step 1: Tonight - preparation
        steps.append(InterventionStep(
            timing: "Tonight",
            action: "Go to bed early to get 8+ hours of sleep",
            reason: "Good sleep is the foundation for better mood",
            reminderTime: Calendar.current.date(bySettingHour: 21, minute: 30, second: 0, of: Date())
        ))
        
        // Step 2: Morning - positive activity
        if let bestActivity = positiveActivities.first {
            steps.append(InterventionStep(
                timing: "Tomorrow morning",
                action: "Try \(bestActivity.trigger.lowercased()) before starting your day",
                reason: "\(bestActivity.trigger) boosts your mood by \(String(format: "%.1f", bestActivity.impact)) points",
                reminderTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    .flatMap { Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: $0) }
            ))
        } else {
            steps.append(InterventionStep(
                timing: "Tomorrow morning",
                action: "Take a 10-minute walk or do light exercise",
                reason: "Physical activity typically improves mood",
                reminderTime: Calendar.current.date(byAdding: .day, value: 1, to: Date())
                    .flatMap { Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: $0) }
            ))
        }
        
        // Step 3: During day - coping strategy
        steps.append(InterventionStep(
            timing: "During the day",
            action: "Take 5-minute breaks between tasks",
            reason: "Prevents mood crashes during stressful periods"
        ))
        
        // If API configured, get AI-generated plan
        if Config.isConfigured {
            do {
                let aiSteps = try await generateAIInterventionSteps(prediction: prediction, patterns: userPatterns)
                if !aiSteps.isEmpty {
                    steps = aiSteps
                }
            } catch {
                print("AI intervention generation failed, using template: \(error)")
            }
        }
        
        let predictedImprovement = positiveActivities.first?.impact ?? 1.0
        
        return InterventionPlan(
            steps: steps,
            predictedImprovement: predictedImprovement,
            generatedBy: Config.isConfigured ? "AI" : "Template"
        )
    }
    
    private func generateAIInterventionSteps(prediction: MoodPrediction, patterns: [DetectedPattern]) async throws -> [InterventionStep] {
        // Use GPT to generate personalized interventions
        let positivePatterns = patterns.filter { $0.impact > 0 }.prefix(3)
        
        let prompt = """
        Generate a 3-step prevention plan for tomorrow's predicted low mood.
        
        Prediction: \(String(format: "%.1f", prediction.predictedMood))/5
        Risk factors:
        \(prediction.riskFactors.map { "- \($0.name): \($0.impact) impact" }.joined(separator: "\n"))
        
        What helps this user (from data):
        \(positivePatterns.map { "- \($0.trigger): +\($0.impact) mood boost" }.joined(separator: "\n"))
        
        Create 3 specific, actionable steps:
        1. Tonight action
        2. Morning action  
        3. During day action
        
        Format each as:
        [Timing]|[Action]|[Reason with data]
        
        Example:
        Tonight|Go to bed by 10 PM|Sleep 8+ hours improves your mood by +1.2 points
        Tomorrow morning|20-minute workout|Exercise boosts your mood by +2.0 points
        During the day|Take breaks between meetings|Prevents your typical 3 PM mood crash
        """
        
        let aiService = AIService()
        let response = try await aiService.callOpenAIForAnalysis(prompt: prompt)
        
        // Parse response into steps
        let lines = response.components(separatedBy: "\n").filter { !$0.isEmpty }
        var steps: [InterventionStep] = []
        
        for line in lines {
            let parts = line.components(separatedBy: "|")
            guard parts.count == 3 else { continue }
            
            let timing = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let action = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let reason = parts[2].trimmingCharacters(in: .whitespacesAndNewlines)
            
            steps.append(InterventionStep(
                timing: timing,
                action: action,
                reason: reason
            ))
        }
        
        return steps
    }
    
    // MARK: - Prediction Accuracy Tracking
    
    func trackPredictionResult(prediction: MoodPrediction, actualEntry: MoodEntry, interventionUsed: Bool) -> PredictionResult {
        let result = PredictionResult(
            predictionDate: prediction.date,
            predictedMood: prediction.predictedMood,
            actualMood: Double(actualEntry.moodScore),
            interventionUsed: interventionUsed
        )
        
        return result
    }
    
    // MARK: - Helper Functions
    
    private func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
    
    private func weekdayNumber(for day: String) -> Int {
        switch day {
        case "Sunday": return 1
        case "Monday": return 2
        case "Tuesday": return 3
        case "Wednesday": return 4
        case "Thursday": return 5
        case "Friday": return 6
        case "Saturday": return 7
        default: return 0
        }
    }
}

