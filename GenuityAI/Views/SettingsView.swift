//
//  SettingsView.swift
//  Genuity AI
//
//  Privacy and security settings
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var securityManager = SecurityManager()
    @StateObject private var aiService = AIService()
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var showingPrivacyInfo = false
    @State private var showingCloudAIConsent = false
    @State private var showingDeleteConfirmation = false
    @State private var showingTermsOfService = false
    @State private var showingPrivacyPolicy = false
    
    private func generateExportData() -> String {
        let exportData: [String: Any] = [
            "app": "Genuity AI",
            "version": "1.0.0",
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "totalEntries": dataManager.entries.count,
            "entries": dataManager.entries.map { entry in
                [
                    "id": entry.id.uuidString,
                    "date": ISO8601DateFormatter().string(from: entry.timestamp),
                    "mood": entry.moodScore,
                    "moodEmoji": entry.moodEmoji,
                    "notes": entry.notes,
                    "activities": entry.activities
                ]
            }
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }
        
        return jsonString
    }
    
    var body: some View {
        NavigationView {
            List {
                // Privacy Section
                Section {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.purple)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% Private")
                                .font(.headline)
                            Text("All data stays on your device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Privacy")
                }
                
                // Security Section
                Section {
                    Toggle(isOn: $securityManager.biometricLockEnabled) {
                        HStack {
                            Image(systemName: securityManager.biometricsAvailable().type.icon)
                                .foregroundColor(.purple)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(securityManager.biometricsAvailable().type.displayName)
                                    .font(.subheadline)
                                Text("Lock app with biometrics")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Security")
                } footer: {
                    Text("Require \(securityManager.biometricsAvailable().type.displayName) to open the app")
                }
                
                // AI Mode Section
                Section {
                    Picker("AI Mode", selection: $aiService.aiMode) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Local Only")
                                Text("100% Private")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                        }
                        .tag(SecurityManager.AIMode.local)
                        
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Cloud AI")
                                Text("Better responses")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "cloud.fill")
                                .foregroundColor(.blue)
                        }
                        .tag(SecurityManager.AIMode.cloudOptional)
                    }
                    .pickerStyle(.inline)
                    .onChange(of: aiService.aiMode) { newMode in
                        if newMode == .cloudOptional {
                            showingCloudAIConsent = true
                        }
                    }
                    
                    Button(action: { showingPrivacyInfo = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Privacy Information")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("AI Processing")
                } footer: {
                    Text(aiService.aiMode == .local 
                        ? "All AI processing happens on your device. Your data never leaves your phone." 
                        : "AI responses are processed by OpenAI. Your messages are sent securely but leave your device.")
                }
                
                // HealthKit Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Connect Apple Health")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Better predictions with sleep & exercise data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        
                        if healthKitManager.isAuthorized {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        } else {
                            Button("Connect") {
                                Task {
                                    _ = await healthKitManager.requestAuthorization()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                        }
                    }
                } header: {
                    Text("HealthKit Integration")
                } footer: {
                    Text("Genuity AI can analyze your sleep and exercise data to provide better mood predictions. This data never leaves your device.")
                }
                
                // Data Section
                Section {
                    HStack {
                        Image(systemName: "internaldrive")
                            .foregroundColor(.purple)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Storage")
                                .font(.subheadline)
                            Text("Encrypted Keychain")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.purple)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Entries")
                                .font(.subheadline)
                            Text("\(dataManager.entries.count) mood entries")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ShareLink(
                        item: generateExportData(),
                        subject: Text("My Mood Data - Genuity AI"),
                        message: Text("My mood tracking data from Genuity AI")
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete All Data")
                        }
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Export your mood data as JSON. Share with your therapist or back up to your files.")
                }
                
                // Legal Section
                Section {
                    Button(action: { showingTermsOfService = true }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.purple)
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: { showingPrivacyPolicy = true }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.purple)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Legal")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://syntaxstrategist.github.io/genuity-ai")!) {
                        HStack {
                            Text("Website")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacyInfo) {
                PrivacyInfoView()
            }
            .sheet(isPresented: $showingTermsOfService) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .alert("Enable Cloud AI?", isPresented: $showingCloudAIConsent) {
                Button("Cancel", role: .cancel) {
                    aiService.aiMode = .local
                }
                Button("Enable") {
                    // User confirmed
                }
            } message: {
                Text("Cloud AI provides better conversational responses but sends your messages to OpenAI.\n\nYour mood data always stays on your device.\n\nYou can switch back to Local-Only anytime.")
            }
            .alert("Delete All Data?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    dataManager.clearAllData()
                }
            } message: {
                Text("This will permanently delete all \(dataManager.entries.count) mood entries from your device. This cannot be undone.")
            }
        }
    }
}

struct PrivacyInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.purple.gradient)
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                    Text("Your Privacy is Our Priority")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                    
                    PrivacyPoint(
                        icon: "internaldrive",
                        title: "100% On-Device",
                        description: "All mood tracking, pattern detection, and predictions happen on YOUR device. Your mental health data never leaves your phone."
                    )
                    
                    PrivacyPoint(
                        icon: "lock.fill",
                        title: "Encrypted Storage",
                        description: "Your mood entries are encrypted using iOS Keychain, protected by your device passcode."
                    )
                    
                    PrivacyPoint(
                        icon: "eye.slash.fill",
                        title: "Zero Knowledge",
                        description: "We can't see your data even if we wanted to. There are no servers, no cloud sync, no backdoors."
                    )
                    
                    PrivacyPoint(
                        icon: "wifi.slash",
                        title: "Works Offline",
                        description: "No internet required. Track your mood anywhere, anytime."
                    )
                    
                    PrivacyPoint(
                        icon: "cloud.fill",
                        title: "Optional Cloud AI",
                        description: "If you enable Cloud AI mode, your chat messages (not mood data) are sent to OpenAI for better responses. You control this setting."
                    )
                    
                    PrivacyPoint(
                        icon: "arrow.up.doc",
                        title: "Export Anytime",
                        description: "Your data is yours. Export it as JSON anytime you want."
                    )
                }
                .padding()
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyPoint: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
}

