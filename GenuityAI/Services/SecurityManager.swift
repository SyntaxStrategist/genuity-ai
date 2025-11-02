//
//  SecurityManager.swift
//  Genuity AI
//
//  Biometric authentication and app security
//

import Foundation
import LocalAuthentication
import SwiftUI

@MainActor
class SecurityManager: ObservableObject {
    @AppStorage("biometricLockEnabled") var biometricLockEnabled = false
    @AppStorage("aiMode") private var aiModeRaw = "local"
    
    @Published var isAuthenticated = false
    @Published var authenticationError: String?
    
    var aiMode: AIMode {
        get { AIMode(rawValue: aiModeRaw) ?? .local }
        set { aiModeRaw = newValue.rawValue }
    }
    
    enum AIMode: String {
        case local = "local"           // 100% private, on-device only
        case cloudOptional = "cloud"   // Uses OpenAI (user opted in)
    }
    
    // MARK: - Biometric Authentication
    
    func authenticateUser() async -> Bool {
        guard biometricLockEnabled else {
            isAuthenticated = true
            return true
        }
        
        let context = LAContext()
        var error: NSError?
        
        // Check if biometrics are available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Fallback to passcode
            return await authenticateWithPasscode(context: context)
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock Genuity AI to access your private mood data"
            )
            
            isAuthenticated = success
            return success
        } catch {
            authenticationError = error.localizedDescription
            isAuthenticated = false
            return false
        }
    }
    
    private func authenticateWithPasscode(context: LAContext) async -> Bool {
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock Genuity AI to access your private mood data"
            )
            isAuthenticated = success
            return success
        } catch {
            authenticationError = error.localizedDescription
            isAuthenticated = false
            return false
        }
    }
    
    func lockApp() {
        isAuthenticated = false
    }
    
    // MARK: - Biometric Availability
    
    func biometricsAvailable() -> (available: Bool, type: BiometricType) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return (false, .none)
        }
        
        switch context.biometryType {
        case .faceID:
            return (true, .faceID)
        case .touchID:
            return (true, .touchID)
        case .opticID:
            return (true, .opticID)
        case .none:
            return (false, .none)
        @unknown default:
            return (false, .none)
        }
    }
    
    enum BiometricType {
        case faceID
        case touchID
        case opticID
        case none
        
        var displayName: String {
            switch self {
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            case .opticID: return "Optic ID"
            case .none: return "Passcode"
            }
        }
        
        var icon: String {
            switch self {
            case .faceID: return "faceid"
            case .touchID: return "touchid"
            case .opticID: return "opticid"
            case .none: return "lock.fill"
            }
        }
    }
}

