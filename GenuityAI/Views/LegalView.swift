//
//  LegalView.swift
//  Genuity AI
//
//  Terms of Service and Privacy Policy
//

import SwiftUI

// MARK: - Terms of Service

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    Text("Last Updated: November 2, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Medical Disclaimer
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Medical Disclaimer", systemImage: "exclamationmark.triangle.fill")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text("""
                        **IMPORTANT: THIS APP IS NOT MEDICAL ADVICE**
                        
                        Genuity AI is a mood tracking and self-reflection tool. It is NOT:
                        • A replacement for professional mental health care
                        • Medical advice, diagnosis, or treatment
                        • Crisis intervention or emergency services
                        • A licensed therapist or counselor
                        
                        **IF YOU ARE EXPERIENCING A MENTAL HEALTH CRISIS:**
                        
                        🚨 Call 988 (Suicide & Crisis Lifeline)
                        🚨 Call 911 (Emergency Services)
                        🚨 Go to your nearest emergency room
                        🚨 Contact a licensed mental health professional
                        
                        Do NOT rely on this app for crisis situations.
                        """)
                        .font(.subheadline)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Agreement
                    LegalSection(title: "1. Acceptance of Terms") {
                        Text("""
                        By accessing and using Genuity AI, you accept and agree to be bound by these Terms of Service. If you do not agree, do not use this app.
                        
                        You must be at least 18 years old to use Genuity AI.
                        """)
                    }
                    
                    LegalSection(title: "2. Description of Service") {
                        Text("""
                        Genuity AI provides:
                        • Mood tracking functionality
                        • Pattern detection and analysis
                        • Mood predictions based on historical data
                        • Optional AI-powered chat responses
                        
                        All features are for informational and self-reflection purposes only.
                        """)
                    }
                    
                    LegalSection(title: "3. User Responsibilities") {
                        Text("""
                        You agree to:
                        • Use the app responsibly and at your own risk
                        • Seek professional help for serious mental health concerns
                        • Not rely on the app as a substitute for medical advice
                        • Keep your device secure
                        • Not share sensitive personal information beyond mood tracking
                        """)
                    }
                    
                    LegalSection(title: "4. Limitation of Liability") {
                        Text("""
                        TO THE MAXIMUM EXTENT PERMITTED BY LAW:
                        
                        Genuity AI and its developers are NOT liable for:
                        • Any outcomes resulting from app usage
                        • Decisions made based on app insights
                        • Technical failures or data loss
                        • Inaccurate predictions or patterns
                        • Any damages, direct or indirect
                        
                        YOU USE THIS APP AT YOUR OWN RISK.
                        """)
                    }
                    
                    LegalSection(title: "5. No Warranty") {
                        Text("""
                        The app is provided "AS IS" without warranties of any kind. We do not guarantee:
                        • Accuracy of predictions or insights
                        • Uninterrupted service
                        • Error-free operation
                        • Fitness for any particular purpose
                        """)
                    }
                    
                    LegalSection(title: "6. Privacy & Data") {
                        Text("""
                        • Your data is stored locally on your device
                        • Data is encrypted using iOS Keychain
                        • We cannot access your mood data
                        • Optional cloud AI sends messages to OpenAI
                        • See our Privacy Policy for full details
                        """)
                    }
                    
                    LegalSection(title: "7. Changes to Terms") {
                        Text("""
                        We may modify these terms at any time. Continued use of the app constitutes acceptance of modified terms.
                        """)
                    }
                    
                    LegalSection(title: "8. Contact") {
                        Text("""
                        For questions about these terms:
                        Email: genuityaiapp@gmail.com
                        
                        For mental health emergencies:
                        Call 988 (US) or your local emergency services
                        """)
                    }
                }
                .padding()
            }
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

// MARK: - Privacy Policy

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    Text("Last Updated: November 2, 2025")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Privacy First Badge
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% Private")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text("Your data never leaves your device by default")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    
                    LegalSection(title: "1. Information We Collect") {
                        Text("""
                        **Mood Entries (Local Only):**
                        • Mood scores (1-5 rating)
                        • Your written notes
                        • Activities you mention
                        • Timestamps
                        
                        **Storage:** Encrypted on YOUR device using iOS Keychain
                        
                        **We do NOT collect:**
                        • Your name
                        • Email address
                        • Phone number
                        • Location data
                        • Usage analytics
                        • Any personally identifiable information
                        """)
                    }
                    
                    LegalSection(title: "2. How We Use Your Data") {
                        Text("""
                        **Local Processing (Default Mode):**
                        • Pattern detection (on your device)
                        • Mood predictions (on your device)
                        • Insights generation (on your device)
                        • All processing happens locally
                        • ZERO data transmission
                        
                        **Cloud AI Mode (Optional):**
                        If you enable Cloud AI:
                        • Your chat messages are sent to OpenAI
                        • Used only to generate AI responses
                        • Not used for training (OpenAI policy)
                        • Stored by OpenAI for 30 days
                        • Your mood data NEVER sent (only chat messages)
                        """)
                    }
                    
                    LegalSection(title: "3. Data Sharing") {
                        Text("""
                        **We do NOT share, sell, or transmit your data.**
                        
                        **Local Mode (Default):**
                        • Zero data sharing
                        • Everything stays on your device
                        
                        **Cloud AI Mode (Optional):**
                        • Chat messages sent to OpenAI only
                        • Subject to OpenAI's privacy policy
                        • You can disable anytime
                        
                        **Third Parties:**
                        • No analytics (Google, Facebook, etc.)
                        • No advertising networks
                        • No data brokers
                        """)
                    }
                    
                    LegalSection(title: "4. Data Security") {
                        Text("""
                        **Encryption:**
                        • All mood data encrypted using iOS Keychain
                        • Protected by your device passcode
                        • Secure against unauthorized access
                        
                        **Biometric Lock:**
                        • Optional Face ID/Touch ID protection
                        • You control in Settings
                        
                        **Network Security:**
                        • Local mode: No network calls
                        • Cloud mode: HTTPS encryption only
                        """)
                    }
                    
                    LegalSection(title: "5. Your Rights") {
                        Text("""
                        You have the right to:
                        ✓ Export your data anytime (JSON format)
                        ✓ Delete all data permanently
                        ✓ Choose Local or Cloud AI mode
                        ✓ Disable biometric lock
                        ✓ Stop using the app anytime
                        
                        **Your data is YOURS.**
                        """)
                    }
                    
                    LegalSection(title: "6. Data Retention") {
                        Text("""
                        • Data stored locally until you delete it
                        • No automatic deletion
                        • No cloud backups (unless you export to iCloud)
                        • Deleting the app deletes all data
                        """)
                    }
                    
                    LegalSection(title: "7. Children's Privacy") {
                        Text("""
                        Genuity AI is intended for users 18 years and older. We do not knowingly collect data from children under 18.
                        """)
                    }
                    
                    LegalSection(title: "8. Changes to Privacy Policy") {
                        Text("""
                        We may update this policy. Continued use after changes constitutes acceptance.
                        """)
                    }
                    
                    LegalSection(title: "9. Contact Us") {
                        Text("""
                        Privacy questions:
                        📧 genuityaiapp@gmail.com
                        
                        Crisis support:
                        📞 988 (Suicide & Crisis Lifeline)
                        📞 911 (Emergency)
                        """)
                    }
                }
                .padding()
            }
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

// MARK: - Consent Screen (First Launch)

struct LegalConsentView: View {
    @Binding var hasAgreedToTerms: Bool
    @Binding var isPresented: Bool
    @State private var hasReadTerms = false
    @State private var showingTerms = false
    @State private var showingPrivacy = false
    
    var body: some View {
        ZStack {
            Color.purple.opacity(0.05)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.purple)
                        .padding()
                    
                    Text("Important Notice")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        NoticeItem(
                            icon: "cross.case.fill",
                            color: .red,
                            text: "This app is NOT therapy or medical advice"
                        )
                        
                        NoticeItem(
                            icon: "phone.fill",
                            color: .red,
                            text: "In crisis? Call 988 (Suicide & Crisis Lifeline)"
                        )
                        
                        NoticeItem(
                            icon: "lock.fill",
                            color: .green,
                            text: "Your data stays 100% private on your device"
                        )
                        
                        NoticeItem(
                            icon: "18.circle.fill",
                            color: .orange,
                            text: "You must be 18+ years old to use this app"
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Button(action: { showingTerms = true }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Read Terms of Service")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.subheadline)
                            .foregroundColor(.purple)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showingPrivacy = true }) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                Text("Read Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.subheadline)
                            .foregroundColor(.purple)
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Toggle(isOn: $hasReadTerms) {
                        Text("I have read and agree to the Terms of Service and Privacy Policy")
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .padding(.horizontal)
                    
                    Button(action: {
                        if hasReadTerms {
                            hasAgreedToTerms = true
                            isPresented = false
                        }
                    }) {
                        Text("Continue to Genuity AI")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasReadTerms ? Color.purple : Color.gray)
                            .cornerRadius(16)
                    }
                    .disabled(!hasReadTerms)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding(.vertical, 40)
            }
        }
        .sheet(isPresented: $showingTerms) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyPolicyView()
        }
    }
}

struct NoticeItem: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Legal Section Component

struct LegalSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.purple)
            
            content
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    LegalConsentView(hasAgreedToTerms: .constant(false), isPresented: .constant(true))
}

