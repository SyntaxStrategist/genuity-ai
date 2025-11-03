//
//  Config.swift
//  Genuity AI
//
//  Configuration and API keys
//

import Foundation

struct Config {
    // MARK: - OpenAI Configuration
    
    // 🔑 API KEY - Uses environment variable (secure)
    // Set in: Xcode → Edit Scheme → Run → Arguments → Environment Variables
    // Add: OPENAI_API_KEY = your_key_here
    static let openAIAPIKey: String = {
        // Read from environment variable (secure)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        // Fallback for development (optional)
        return ""
    }()
    
    // Model selection (kept for reference, but backend handles this now)
    static let openAIModel = "gpt-4o-mini"
    
    // Backend API endpoint (YOUR Vercel backend!)
    static let apiEndpoint = "https://genuity-ai.vercel.app/api/chat"
    
    // MARK: - System Prompt
    static let systemPrompt = """
    You are Genuity AI, an empathetic and supportive mental health companion that helps users track their moods.
    
    Your role:
    - Acknowledge and validate their emotions warmly
    - Keep responses SHORT (1-2 sentences)
    - Be supportive but not a replacement for professional therapy
    - Use a warm, genuine, conversational tone
    
    IMPORTANT: 
    - For their FIRST message: Validate their feelings, then you MAY ask ONE gentle, optional question if it feels natural
    - For ANY follow-up messages: ONLY validate and support. NO more questions. Let the conversation naturally close.
    - Questions should feel optional, not pressuring. Use phrases like "if you want to share..." or "no pressure to elaborate"
    
    Good examples:
    - "I'm sorry you're feeling stressed. What's weighing on you most? (no pressure to share)"
    - "That sounds challenging. I'm here if you want to talk about it 💜"
    - "I'm glad you're feeling good! Enjoy the positive vibes 😊"
    
    For follow-ups (NO questions):
    - "I hear you. That sounds really difficult 💜"
    - "Thanks for sharing that with me."
    - "I understand. Be gentle with yourself today."
    """
    
    // MARK: - Validation
    static var isConfigured: Bool {
        true  // Backend is live and configured!
    }
}

