//
//  ChatView.swift
//  Genuity AI
//
//  Conversational AI mood tracking
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var aiService = AIService()
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if messages.isEmpty {
                                welcomeView
                            }
                            
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input area
                VStack(spacing: 8) {
                    // Simpler hint (less is more)
                    if messages.count <= 1 {
                        Text("Just type how you're feeling →")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        TextField("How are you feeling?", text: $messageText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                            .focused($isInputFocused)
                            .lineLimit(1...5)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(messageText.isEmpty ? .gray : .purple)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
            }
            .navigationTitle("Genuity AI")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if messages.isEmpty {
                    addWelcomeMessage()
                }
                // Give AI context from past entries
                aiService.setContext(from: dataManager.entries)
            }
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 24) {
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            
            Text("Daily Check-In")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tell me how you're feeling today")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                HintRow(icon: "1.circle.fill", text: "One quick message is enough")
                HintRow(icon: "2.circle.fill", text: "I'll remember context over time")
                HintRow(icon: "3.circle.fill", text: "Patterns unlock after 3 days")
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
    
    private func addWelcomeMessage() {
        let welcome = ChatMessage(
            text: "Hi! I'm your Genuity AI companion. How are you feeling today?",
            isUser: false,
            timestamp: Date()
        )
        messages.append(welcome)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            text: messageText,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        let userText = messageText
        messageText = ""
        
        // Call AI asynchronously
        Task {
            do {
                // Get AI response
                let response = try await aiService.generateResponse(to: userText)
                let aiMessage = ChatMessage(
                    text: response,
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(aiMessage)
                
                // Fetch HealthKit data if available
                let healthData = await healthKitManager.fetchAllTodayData()
                
                // Extract and save mood entry with HealthKit context
                var entry = try await aiService.extractMoodEntry(from: userText)
                entry.sleepHours = healthData.sleepHours
                entry.exerciseMinutes = healthData.exerciseMinutes
                entry.stepCount = healthData.steps
                
                dataManager.addEntry(entry)
                
            } catch {
                // Show error message
                let errorMessage = ChatMessage(
                    text: "⚠️ Couldn't process that. Please try again.",
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(errorMessage)
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color.purple : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser { Spacer() }
        }
        .id(message.id)
    }
}

struct HintRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple)
                .font(.title3)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(DataManager())
}

