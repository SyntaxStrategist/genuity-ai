//
//  OnboardingView.swift
//  Genuity AI
//
//  First-time user onboarding
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color.purple.opacity(0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color.purple : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 40)
                
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    OnboardingPage(
                        icon: "brain.head.profile",
                        title: "Welcome to Genuity AI",
                        description: "Your personal mental health companion that understands you.",
                        details: "I'll help you track your mood and discover patterns in your emotional well-being."
                    )
                    .tag(0)
                    
                    // Page 2: How it works
                    OnboardingPage(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Just Talk Naturally",
                        description: "Tell me how you're feeling once a day.",
                        details: "No buttons, no forms. Just a quick check-in:\n\n\"Feeling stressed about work\"\n\"Had an amazing day!\"\n\"Pretty tired today\"\n\nThat's it. I'll do the rest."
                    )
                    .tag(1)
                    
                    // Page 3: See patterns
                    OnboardingPage(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Discover Your Patterns",
                        description: "After 7 days, see insights about your mood.",
                        details: "I'll show you:\n• What affects your mood\n• When you're happiest\n• Triggers for stress\n• Trends over time"
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage < 2 {
                        Button(action: { currentPage += 1 }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(16)
                        }
                        
                        Button(action: { isPresented = false }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button(action: {
                            isPresented = false
                            // Request notification permission
                            NotificationManager.shared.requestPermission()
                        }) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Enable Daily Reminders")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(16)
                        }
                        
                        Button(action: { isPresented = false }) {
                            Text("Maybe Later")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let details: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            if icon == "brain.head.profile" {
                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding()
            } else {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundStyle(.purple.gradient)
                    .padding()
            }
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(description)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(details)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineSpacing(4)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}

