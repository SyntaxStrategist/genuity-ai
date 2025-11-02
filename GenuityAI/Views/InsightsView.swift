//
//  InsightsView.swift
//  Genuity AI
//
//  AI-powered insights and patterns
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var aiService = AIService()
    @State private var selectedTimeframe: Timeframe = .week
    @State private var aiInsights: [String] = []
    @State private var isLoadingInsights = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if dataManager.entries.isEmpty {
                        emptyStateView
                    } else {
                        // Show different content based on entries count
                        if dataManager.entries.count == 1 {
                            day1InsightsView
                        } else if dataManager.entries.count < 3 {
                            day2InsightsView
                        } else {
                            // Real insights (3+ days)
                            realInsightsView
                            
                            // Add predictions if 7+ days
                            if dataManager.entries.count >= 7 {
                                predictionsSection
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Insights")
            .background(Color(.systemGroupedBackground))
            .task {
                if dataManager.entries.count >= 3 {
                    await loadAIInsights()
                }
            }
            .refreshable {
                if dataManager.entries.count >= 3 {
                    await loadAIInsights()
                }
            }
        }
    }
    
    private func loadAIInsights() async {
        isLoadingInsights = true
        do {
            aiInsights = try await aiService.generateAIInsights(from: dataManager.entries)
        } catch {
            print("Failed to load insights: \(error)")
        }
        isLoadingInsights = false
    }
    
    // PREDICTIONS SECTION (merged from PredictionsView)
    @StateObject private var patternEngine = PatternEngine()
    
    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider()
                .padding(.vertical)
            
            Text("🔮 Predictions")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text("Based on your patterns, here's what to expect:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if let prediction = patternEngine.currentPrediction {
                PredictionCard(prediction: prediction)
                    .padding(.horizontal)
            } else {
                Text("Analyzing your patterns...")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .onAppear {
            let patterns = patternEngine.detectPatterns(from: dataManager.entries)
            if !patterns.isEmpty {
                patternEngine.currentPrediction = patternEngine.generatePrediction(from: dataManager.entries)
            }
        }
    }
    
    // DAY 1: First entry - show immediate value WITH CHART!
    private var day1InsightsView: some View {
        VStack(spacing: 24) {
            // Show their mood right away!
            if let firstEntry = dataManager.entries.first {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your First Entry")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // IMMEDIATE VISUAL FEEDBACK
                    HStack(spacing: 40) {
                        VStack {
                            Text(firstEntry.moodEmoji)
                                .font(.system(size: 64))
                            Text("\(firstEntry.moodScore)/5")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.purple)
                            Text("Your Mood")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What this means:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if firstEntry.moodScore >= 4 {
                                Text("✨ You're feeling good! Track daily to understand what keeps you here.")
                            } else if firstEntry.moodScore >= 3 {
                                Text("👍 Baseline captured. I'll help you identify what boosts this.")
                            } else {
                                Text("💜 Tough day noted. In 3 days, I'll find patterns to help prevent these.")
                            }
                        }
                        .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(
                        LinearGradient(colors: [Color.purple.opacity(0.1), Color.purple.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(16)
                    
                    // What's coming
                    VStack(alignment: .leading, spacing: 16) {
                        Text("📈 What You'll Unlock:")
                            .font(.headline)
                            .foregroundColor(.purple)
                        
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("3 Days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Pattern Detection")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.purple)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("7 Days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Mood Predictions")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10)
                .padding(.horizontal)
            }
            
            Text("Come back tomorrow! 💜")
                .font(.headline)
                .foregroundColor(.purple)
                .padding()
        }
        .padding(.vertical, 20)
    }
    
    // DAY 2: Early patterns emerging
    private var day2InsightsView: some View {
        Day2InsightsContent(entries: dataManager.entries)
    }
    
    // DAY 3+: Real AI insights
    private var realInsightsView: some View {
        VStack(spacing: 24) {
            // Header with entry count
            VStack(spacing: 8) {
                Text("🧠 Your Insights")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Based on \(dataManager.entries.count) entries")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // AI-Generated Insights Card
            aiGeneratedInsightsCard
            
            // Mood Chart
            moodTrendCard
            
            // Activity Correlation Card
            activityCorrelationCard
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            
            Text("Start Your Journey")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Track your mood to discover what makes YOU happy.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "1.circle.fill")
                        .foregroundColor(.purple)
                    Text("Go to Chat tab")
                        .font(.subheadline)
                }
                HStack {
                    Image(systemName: "2.circle.fill")
                        .foregroundColor(.purple)
                    Text("Tell me how you're feeling")
                        .font(.subheadline)
                }
                HStack {
                    Image(systemName: "3.circle.fill")
                        .foregroundColor(.purple)
                    Text("Come back here to see insights")
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical, 60)
    }
    
    private var moodTrendCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Mood Trends", systemImage: "chart.xyaxis.line")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(dataManager.recentEntries(days: daysForTimeframe)) { entry in
                        LineMark(
                            x: .value("Date", entry.timestamp),
                            y: .value("Mood", entry.moodScore)
                        )
                        .foregroundStyle(.purple.gradient)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 1...5)
            } else {
                Text("Charts require iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    // REAL AI-Generated Insights Card
    private var aiGeneratedInsightsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("AI Discoveries", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Spacer()
                
                if isLoadingInsights {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if aiInsights.isEmpty && !isLoadingInsights {
                Text("Pull to refresh to generate insights")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(aiInsights.enumerated()), id: \.offset) { index, insight in
                        HStack(alignment: .top, spacing: 12) {
                            Text(insight)
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            
            Text("💡 These insights are personalized to YOUR data")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    // Activity Correlation Card
    private var activityCorrelationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Activity Impact", systemImage: "chart.bar.fill")
                .font(.headline)
            
            let activityMoods = calculateActivityCorrelations()
            
            if activityMoods.isEmpty {
                Text("Track more activities to see patterns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(activityMoods.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { activity, avgMood in
                        HStack {
                            Text(activity)
                                .font(.subheadline)
                            Spacer()
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f", avgMood))
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                Text("/5")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: avgMood >= 4 ? "arrow.up.circle.fill" : avgMood >= 3 ? "minus.circle.fill" : "arrow.down.circle.fill")
                                    .foregroundColor(avgMood >= 4 ? .green : avgMood >= 3 ? .orange : .red)
                            }
                        }
                        .padding(.vertical, 8)
                        Divider()
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
    
    private func calculateActivityCorrelations() -> [String: Double] {
        var activityMoods: [String: [Int]] = [:]
        
        for entry in dataManager.entries {
            for activity in entry.activities {
                activityMoods[activity, default: []].append(entry.moodScore)
            }
        }
        
        var result: [String: Double] = [:]
        for (activity, moods) in activityMoods where moods.count >= 2 {
            let avg = Double(moods.reduce(0, +)) / Double(moods.count)
            result[activity] = avg
        }
        
        return result
    }
    
    private var daysForTimeframe: Int {
        switch selectedTimeframe {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
}

struct InsightRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct PatternBadge: View {
    let emoji: String
    let label: String
    
    var body: some View {
        HStack {
            Text(emoji)
            Text(label)
                .font(.subheadline)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.purple.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(.purple)
        }
    }
}

struct Day2InsightsContent: View {
    let entries: [MoodEntry]
    
    var body: some View {
        let avgMood = Double(entries.map(\.moodScore).reduce(0, +)) / Double(entries.count)
        let highest = entries.max(by: { $0.moodScore < $1.moodScore })
        
        return VStack(spacing: 24) {
            Text("📊 Early Patterns")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("You have \(entries.count) entries. Patterns are starting to emerge!")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Show basic stats
            VStack(alignment: .leading, spacing: 16) {
                StatRow(icon: "chart.bar.fill", label: "Average Mood", value: String(format: "%.1f/5", avgMood))
                StatRow(icon: "calendar.badge.clock", label: "Check-ins", value: "\(entries.count)")
                
                if let bestDay = highest {
                    StatRow(icon: "arrow.up.circle.fill", label: "Best Day", value: "\(bestDay.timestamp.formatted(date: .abbreviated, time: .omitted))")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10)
            .padding(.horizontal)
            
            // Progress to 3 days
            VStack(spacing: 12) {
                Text("✨ One more check-in to unlock AI insights!")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                HStack(spacing: 8) {
                    ForEach(0..<3) { day in
                        ProgressCircle(day: day, completedCount: entries.count)
                    }
                }
                
                Text("After 3 entries, AI will analyze your data and find personalized patterns")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
}

struct ProgressCircle: View {
    let day: Int
    let completedCount: Int
    
    var isCompleted: Bool {
        day < completedCount
    }
    
    var body: some View {
        Circle()
            .fill(isCompleted ? Color.purple : Color.gray.opacity(0.3))
            .frame(width: 40, height: 40)
            .overlay(
                Group {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    } else {
                        Text("\(day + 1)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            )
    }
}

// MARK: - Prediction Card (simplified from PredictionsView)
struct PredictionCard: View {
    let prediction: MoodPrediction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text(prediction.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Predicted Mood: \(String(format: "%.1f", prediction.predictedMood))/5")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
                Text(moodEmoji(for: prediction.predictedMood))
                    .font(.system(size: 50))
            }
            
            if !prediction.riskFactors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ Watch Out For:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    ForEach(prediction.riskFactors, id: \.self) { factor in
                        Text("• \(factor)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !prediction.interventionPlan.steps.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💪 Prevention Plan:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    ForEach(prediction.interventionPlan.steps.prefix(3), id: \.id) { step in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.action)
                                    .font(.subheadline)
                                Text(step.timing)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    private func moodEmoji(for score: Double) -> String {
        switch score {
        case 4.5...: return "😄"
        case 3.5..<4.5: return "🙂"
        case 2.5..<3.5: return "😐"
        case 1.5..<2.5: return "😕"
        default: return "😢"
        }
    }
}

#Preview {
    InsightsView()
        .environmentObject(DataManager())
}

