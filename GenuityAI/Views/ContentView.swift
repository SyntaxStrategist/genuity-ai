//
//  ContentView.swift
//  Genuity AI
//
//  Main navigation view
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasAgreedToTerms") private var hasAgreedToTerms = false
    @State private var selectedTab = 0
    @State private var showOnboarding = false
    @State private var showLegalConsent = false
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(0)
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(.purple)
        .fullScreenCover(isPresented: $showLegalConsent) {
            LegalConsentView(hasAgreedToTerms: $hasAgreedToTerms, isPresented: $showLegalConsent)
                .interactiveDismissDisabled()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
        .onAppear {
            // Show onboarding first (no legal wall!)
            if !hasCompletedOnboarding {
                showOnboarding = true
                hasCompletedOnboarding = true
            }
        }
        .onChange(of: dataManager.entries.count) { count in
            // Show legal consent AFTER first entry (better UX!)
            if count == 1 && !hasAgreedToTerms {
                showLegalConsent = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}

