//
//  GenuityAIApp.swift
//  Genuity AI
//
//  Your genuine self, understood by AI
//

import SwiftUI

@main
struct GenuityAIApp: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var securityManager = SecurityManager()
    
    var body: some Scene {
        WindowGroup {
            if securityManager.isAuthenticated || !securityManager.biometricLockEnabled {
                ContentView()
                    .environmentObject(dataManager)
                    .environmentObject(securityManager)
            } else {
                BiometricLockScreen()
                    .environmentObject(securityManager)
            }
        }
    }
}

struct BiometricLockScreen: View {
    @EnvironmentObject var securityManager: SecurityManager
    
    var body: some View {
        ZStack {
            Color.purple.opacity(0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 12) {
                    Text("Genuity AI")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your private mood companion")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    Task {
                        _ = await securityManager.authenticateUser()
                    }
                }) {
                    HStack {
                        Image(systemName: securityManager.biometricsAvailable().type.icon)
                        Text("Unlock with \(securityManager.biometricsAvailable().type.displayName)")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                
                if let error = securityManager.authenticationError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .task {
            // Auto-attempt authentication on appear
            _ = await securityManager.authenticateUser()
        }
    }
}

