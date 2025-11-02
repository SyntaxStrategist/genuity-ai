//
//  NotificationManager.swift
//  Genuity AI
//
//  Daily mood check-in notifications
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Permission
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.scheduleDailyReminders()
                }
            }
            
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Schedule Daily Reminders
    
    func scheduleDailyReminders() {
        // Clear existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Morning reminder (9 AM)
        scheduleDailyNotification(
            id: "morning-checkin",
            hour: 9,
            minute: 0,
            title: "Good morning! 🌅",
            body: "How are you feeling today?"
        )
        
        // Evening reminder (8 PM)
        scheduleDailyNotification(
            id: "evening-checkin",
            hour: 20,
            minute: 0,
            title: "Evening check-in 🌙",
            body: "How was your day?"
        )
    }
    
    private func scheduleDailyNotification(id: String, hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✓ Scheduled daily notification: \(id)")
            }
        }
    }
    
    // MARK: - Predictive Alerts
    
    func schedulePredictiveAlert(prediction: MoodPrediction) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(prediction.riskLevel.emoji) Mood Alert"
        content.body = "Tomorrow's predicted mood: \(String(format: "%.1f", prediction.predictedMood))/5. Tap to see your prevention plan."
        content.sound = .default
        content.badge = 1
        
        // Schedule for tonight at 8 PM
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "predictive-alert-\(prediction.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule predictive alert: \(error)")
            } else {
                print("✓ Scheduled predictive alert for tomorrow")
            }
        }
    }
    
    func scheduleInterventionReminder(at date: Date, title: String, body: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "intervention-\(UUID())", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule intervention reminder: \(error)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications canceled")
    }
}

