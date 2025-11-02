//
//  AIService.swift
//  Genuity AI
//
//  AI-powered mood analysis and conversation
//

import Foundation

@MainActor
class AIService: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var aiMode: SecurityManager.AIMode = .local
    
    private var conversationHistory: [[String: String]] = []
    private var recentMoodEntries: [MoodEntry] = []  // Context memory!
    
    // MARK: - Main AI Response Generation (LOCAL-FIRST)
    
    func generateResponse(to userMessage: String) async throws -> String {
        // DEFAULT: Use local AI (100% private)
        if aiMode == .local {
            return generateLocalResponse(to: userMessage)
        }
        
        // OPTIONAL: Use cloud AI (if user enabled it)
        if aiMode == .cloudOptional {
            // Check if API key is configured
            guard Config.isConfigured else {
                // Fallback to local if cloud fails
                return generateLocalResponse(to: userMessage)
            }
            
            do {
                return try await generateCloudResponse(to: userMessage)
            } catch {
                // Fallback to local if cloud fails
                print("Cloud AI failed, using local: \(error)")
                return generateLocalResponse(to: userMessage)
            }
        }
        
        return generateLocalResponse(to: userMessage)
    }
    
    // MARK: - Local AI (100% Private - No Internet Required)
    // NOW WITH CONTEXT AWARENESS!
    
    func setContext(from entries: [MoodEntry]) {
        self.recentMoodEntries = Array(entries.prefix(7))  // Remember last 7 days
    }
    
    private func generateLocalResponse(to userMessage: String) -> String {
        let lowercased = userMessage.lowercased()
        
        // FIRST: Check if first message (special welcome)
        if conversationHistory.isEmpty {
            conversationHistory.append(["role": "user", "content": userMessage])
            return generateFirstMessageResponse(to: userMessage, lowercased: lowercased)
        }
        
        conversationHistory.append(["role": "user", "content": userMessage])
        
        // CONTEXT-AWARE RESPONSES (references past entries)
        if let lastEntry = recentMoodEntries.first, recentMoodEntries.count > 1 {
            // Compare to yesterday
            if recentMoodEntries.count >= 2 {
                let previousEntry = recentMoodEntries[1]
                
                // Detect improvement
                if lowercased.contains("better") || lowercased.contains("good") || lowercased.contains("great") {
                    if previousEntry.moodScore <= 2 {
                        return "I'm so glad you're feeling better! Yesterday seemed tough. What changed? 💜"
                    }
                }
                
                // Detect decline
                if lowercased.contains("worse") || lowercased.contains("bad") || lowercased.contains("stressed") {
                    if previousEntry.moodScore >= 4 {
                        return "I noticed a shift from yesterday. What happened? Want to talk about it?"
                    }
                }
            }
            
            // Activity-based context
            if lastEntry.activities.contains("Exercise") && (lowercased.contains("tired") || lowercased.contains("exhausted")) {
                return "You mentioned exercise recently. Maybe your body needs recovery time?"
            }
        }
        
        // PATTERN-BASED RESPONSES (if we have enough data)
        if recentMoodEntries.count >= 5 {
            let avgMood = Double(recentMoodEntries.reduce(0) { $0 + $1.moodScore }) / Double(recentMoodEntries.count)
            
            if lowercased.contains("sad") || lowercased.contains("down") {
                if avgMood >= 3.5 {
                    return "This seems unusual for you - you've been doing well lately. Anything specific today?"
                } else {
                    return "I've noticed this pattern this week. Let's figure out what's causing it together 💜"
                }
            }
        }
        
        // STANDARD EMPATHETIC RESPONSES (improved)
        if lowercased.contains("great") || lowercased.contains("amazing") || lowercased.contains("happy") || lowercased.contains("excited") {
            let responses = [
                "That's wonderful! 😊 What's the highlight?",
                "Love to hear it! What made today great?",
                "Awesome! Tell me more!"
            ]
            return responses.randomElement() ?? responses[0]
        } else if lowercased.contains("sad") || lowercased.contains("down") || lowercased.contains("depressed") {
            return "I'm here with you 💜 No pressure to share, but I'm listening if you want to."
        } else if lowercased.contains("anxious") || lowercased.contains("worried") || lowercased.contains("stressed") {
            return "Stress is hard. Take a breath. What's on your mind?"
        } else if lowercased.contains("tired") || lowercased.contains("exhausted") {
            return "Sounds like you need rest. How's your sleep been?"
        } else if lowercased.contains("angry") || lowercased.contains("frustrated") {
            return "I hear your frustration. It's valid. What happened?"
        } else if lowercased.contains("okay") || lowercased.contains("fine") || lowercased.contains("alright") {
            return "Just okay? That's honest. Anything you want to share?"
        } else {
            return "Got it. I'm tracking this. Come back tomorrow and I'll spot more patterns 💜"
        }
    }
    
    private func generateFirstMessageResponse(to userMessage: String, lowercased: String) -> String {
        // More natural first responses
        if lowercased.contains("great") || lowercased.contains("good") || lowercased.contains("happy") {
            return "Great to meet you on a good day! 😊 I've saved this. Check back after a few days to see patterns."
        } else if lowercased.contains("sad") || lowercased.contains("bad") || lowercased.contains("stressed") {
            return "Thanks for trusting me with this 💜 I'll help you spot what leads to days like this. How are you taking care of yourself today?"
        } else if lowercased.contains("tired") || lowercased.contains("exhausted") {
            return "Noted. I'll watch for sleep patterns. Want to share more, or is that it for today?"
        } else {
            return "Got it, thanks for sharing. That's all I need for today! Come back tomorrow 💜"
        }
    }
    
    // MARK: - Cloud AI (Optional - User Opted In)
    
    private func generateCloudResponse(to userMessage: String) async throws -> String {
        // Add user message to history
        conversationHistory.append([
            "role": "user",
            "content": userMessage
        ])
        
        // Prepare the request to YOUR backend
        guard let url = URL(string: Config.apiEndpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        // Build the messages array with system prompt
        var messages: [[String: String]] = [
            ["role": "system", "content": Config.systemPrompt]
        ]
        messages.append(contentsOf: conversationHistory)
        
        let requestBody: [String: Any] = [
            "messages": messages
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make the API call to YOUR backend
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Backend API Error: \(errorBody)")
            throw AIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        // Parse the response from YOUR backend
        let backendResponse = try JSONDecoder().decode(BackendResponse.self, from: data)
        
        let aiMessage = backendResponse.message
        
        // Add AI response to history
        conversationHistory.append([
            "role": "assistant",
            "content": aiMessage
        ])
        
        return aiMessage
    }
    
    // MARK: - Mood Entry Extraction (LOCAL-ONLY)
    
    func extractMoodEntry(from message: String) async throws -> MoodEntry {
        // ALWAYS use local extraction (100% private)
        // Cloud AI is only for chat responses, not data extraction
        
        let moodScore = detectMoodScore(from: message)
        let activities = extractActivities(from: message)
        
        return MoodEntry(
            moodScore: moodScore,
            notes: message,
            activities: activities
        )
    }
    
    private func callOpenAIForExtraction(prompt: String) async throws -> String {
        guard let url = URL(string: Config.apiEndpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": Config.openAIModel,
            "messages": [
                ["role": "system", "content": "You are a mood analysis AI. Respond only with valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 100
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BackendResponse.self, from: data)
        
        return response.message
    }
    
    private func parseExtractionResponse(_ response: String) -> (moodScore: Int, activities: [String])? {
        // Try to extract JSON from response
        guard let jsonData = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let moodScore = json["moodScore"] as? Int,
              let activities = json["activities"] as? [String] else {
            return nil
        }
        
        return (moodScore, activities.isEmpty ? ["General"] : activities)
    }
    
    // Analyze sentiment and return mood score (1-5)
    private func detectMoodScore(from text: String) -> Int {
        let lowercased = text.lowercased()
        
        // Very positive
        if lowercased.contains("amazing") || lowercased.contains("fantastic") || 
           lowercased.contains("wonderful") || lowercased.contains("excited") {
            return 5
        }
        // Positive
        else if lowercased.contains("good") || lowercased.contains("happy") || 
                lowercased.contains("great") || lowercased.contains("better") {
            return 4
        }
        // Negative
        else if lowercased.contains("bad") || lowercased.contains("sad") || 
                lowercased.contains("worried") || lowercased.contains("stressed") {
            return 2
        }
        // Very negative
        else if lowercased.contains("terrible") || lowercased.contains("awful") || 
                lowercased.contains("depressed") || lowercased.contains("hopeless") {
            return 1
        }
        // Neutral
        else {
            return 3
        }
    }
    
    // Extract activities mentioned in the message
    private func extractActivities(from text: String) -> [String] {
        let lowercased = text.lowercased()
        var activities: [String] = []
        
        let activityKeywords = [
            ("work", "Work"),
            ("exercise", "Exercise"),
            ("gym", "Exercise"),
            ("friends", "Social"),
            ("family", "Family"),
            ("sleep", "Sleep"),
            ("tired", "Sleep"),
            ("read", "Reading"),
            ("movie", "Entertainment"),
            ("netflix", "Entertainment"),
            ("cook", "Cooking"),
            ("eat", "Food"),
            ("walk", "Outdoor"),
            ("nature", "Outdoor"),
            ("music", "Music"),
            ("meditat", "Meditation"),
            ("yoga", "Yoga")
        ]
        
        for (keyword, activity) in activityKeywords {
            if lowercased.contains(keyword) && !activities.contains(activity) {
                activities.append(activity)
            }
        }
        
        return activities.isEmpty ? ["General"] : activities
    }
    
    // Generate insights (LOCAL-FIRST, cloud optional)
    func generateAIInsights(from entries: [MoodEntry]) async throws -> [String] {
        guard !entries.isEmpty else {
            return ["Start tracking to see personalized insights"]
        }
        
        // DEFAULT: Use local insights (100% private)
        if aiMode == .local {
            return generateBasicInsights(from: entries)
        }
        
        // OPTIONAL: Use cloud AI if user enabled it
        if aiMode == .cloudOptional && Config.isConfigured {
            // Prepare data summary for AI analysis
            let dataForAnalysis = prepareDataForAnalysis(entries)
        
        let analysisPrompt = """
        Analyze this user's mood tracking data and generate 3-4 specific, actionable insights.
        
        Data Summary:
        \(dataForAnalysis)
        
        Requirements:
        - Find SPECIFIC patterns (not generic advice)
        - Be actionable ("Try X" not "X is important")
        - Use data to support claims
        - Keep each insight to 1-2 sentences
        - Be warm and encouraging, not clinical
        
        Format each insight on a new line starting with an emoji.
        
        Examples of GOOD insights:
        - "💪 You're 60% happier on days you exercise before work vs after (4.5/5 vs 2.8/5)"
        - "😴 Your mood drops 30% on days you sleep less than 7 hours"
        - "👥 Social activities boost your mood by +2 points on average"
        
        Generate insights now:
        """
        
            do {
                let response = try await callOpenAIForAnalysis(prompt: analysisPrompt)
                let insights = response
                    .components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty && $0.count > 10 }
                
                return insights.isEmpty ? generateBasicInsights(from: entries) : insights
            } catch {
                print("Cloud AI insight generation failed: \(error)")
                return generateBasicInsights(from: entries)
            }
        }
        
        // Default to local
        return generateBasicInsights(from: entries)
    }
    
    // Prepare mood data in readable format for AI
    private func prepareDataForAnalysis(_ entries: [MoodEntry]) -> String {
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        let recentEntries = Array(sortedEntries.prefix(20))
        
        var summary = "Total entries: \(entries.count)\n\n"
        
        // Average mood
        let avgMood = Double(entries.map(\.moodScore).reduce(0, +)) / Double(entries.count)
        summary += "Average mood: \(String(format: "%.1f", avgMood))/5\n\n"
        
        // Activity correlations
        var activityMoods: [String: [Int]] = [:]
        for entry in entries {
            for activity in entry.activities {
                activityMoods[activity, default: []].append(entry.moodScore)
            }
        }
        
        summary += "Activity correlations:\n"
        for (activity, moods) in activityMoods.sorted(by: { $0.key < $1.key }) {
            let avg = Double(moods.reduce(0, +)) / Double(moods.count)
            summary += "- \(activity): \(String(format: "%.1f", avg))/5 avg (\(moods.count) times)\n"
        }
        
        summary += "\nRecent entries:\n"
        for (index, entry) in recentEntries.prefix(10).enumerated() {
            let dateStr = entry.timestamp.formatted(date: .abbreviated, time: .omitted)
            summary += "\(index + 1). \(dateStr): Mood \(entry.moodScore)/5, Activities: \(entry.activities.joined(separator: ", "))\n"
            if !entry.notes.isEmpty {
                summary += "   Note: \(entry.notes.prefix(100))\n"
            }
        }
        
        return summary
    }
    
    // Call OpenAI for insight analysis (made internal for PatternEngine access)
    func callOpenAIForAnalysis(prompt: String) async throws -> String {
        guard let url = URL(string: Config.apiEndpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Config.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": Config.openAIModel,
            "messages": [
                ["role": "system", "content": "You are an insightful mood analysis AI that finds specific, actionable patterns in mood data."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 300
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BackendResponse.self, from: data)
        
        return response.message
    }
    
    // Fallback basic insights (when AI fails or not configured)
    private func generateBasicInsights(from entries: [MoodEntry]) -> [String] {
        var insights: [String] = []
        
        // Average mood
        let avgMood = Double(entries.map(\.moodScore).reduce(0, +)) / Double(entries.count)
        insights.append("📊 Your average mood is \(String(format: "%.1f", avgMood))/5 over \(entries.count) entries")
        
        // Activity analysis
        var activityMoods: [String: [Int]] = [:]
        for entry in entries {
            for activity in entry.activities {
                activityMoods[activity, default: []].append(entry.moodScore)
            }
        }
        
        // Find best activity
        if let bestActivity = activityMoods.max(by: { 
            let avg1 = Double($0.value.reduce(0, +)) / Double($0.value.count)
            let avg2 = Double($1.value.reduce(0, +)) / Double($1.value.count)
            return avg1 < avg2
        }), bestActivity.value.count >= 2 {
            let avg = Double(bestActivity.value.reduce(0, +)) / Double(bestActivity.value.count)
            insights.append("💪 \"\(bestActivity.key)\" correlates with your highest moods (\(String(format: "%.1f", avg))/5 avg)")
        }
        
        // Trend analysis
        if entries.count >= 5 {
            let recent = entries.prefix(3).map(\.moodScore)
            let older = entries.suffix(min(3, entries.count)).map(\.moodScore)
            let recentAvg = Double(recent.reduce(0, +)) / Double(recent.count)
            let olderAvg = Double(older.reduce(0, +)) / Double(older.count)
            
            if recentAvg > olderAvg + 0.5 {
                insights.append("📈 Your mood is trending upward recently!")
            } else if recentAvg < olderAvg - 0.5 {
                insights.append("📉 Your mood has been lower lately - be gentle with yourself")
            } else {
                insights.append("➡️ Your mood has been relatively stable")
            }
        }
        
        // Time-based insight
        if entries.count >= 7 {
            insights.append("✨ Keep tracking! More data = better insights about what makes YOU happy")
        }
        
        return insights
    }
    
    // MARK: - Helper Methods
    
    func resetConversation() {
        conversationHistory.removeAll()
    }
}

// MARK: - Models

struct BackendResponse: Codable {
    let message: String
    let usage: Usage?
    
    struct Usage: Codable {
        let prompt_tokens: Int?
        let completion_tokens: Int?
        let total_tokens: Int?
    }
}

enum AIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case noResponse
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .apiError(let statusCode, let message):
            return "API Error (\(statusCode)): \(message)"
        case .noResponse:
            return "No response from AI"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
