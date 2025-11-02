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
                .badge(dataManager.entries.count < 3 ? "🔒" : "")
                .tag(1)
            
            PredictionsView()
                .tabItem {
                    Label("Predict", systemImage: "sparkles")
                }
                .badge(dataManager.entries.count < 7 ? "🔒" : "")
                .tag(2)
            
            EffectivenessView(dataManager: dataManager)
                .tabItem {
                    Label("Results", systemImage: "chart.bar.doc.horizontal")
                }
                .badge(dataManager.effectivenessReports.isEmpty ? "🔒" : "")
                .tag(3)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .badge(dataManager.entries.count)
                .tag(4)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
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
            // Show legal consent FIRST, then onboarding
            if !hasAgreedToTerms {
                showLegalConsent = true
            } else if !hasCompletedOnboarding {
                showOnboarding = true
                hasCompletedOnboarding = true
            }
        }
        .onChange(of: hasAgreedToTerms) { agreed in
            if agreed && !hasCompletedOnboarding {
                showOnboarding = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}

