//
//  MoodEntry.swift
//  Genuity AI
//
//  Data model for mood entries
//

import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let moodScore: Int // 1-5 scale
    let notes: String
    let activities: [String]
    
    // Context data (HealthKit integration)
    var sleepHours: Double?
    var exerciseMinutes: Int?
    var stepCount: Int?
    
    var moodEmoji: String {
        switch moodScore {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }
    
    init(id: UUID = UUID(), timestamp: Date = Date(), moodScore: Int, notes: String, activities: [String] = [], sleepHours: Double? = nil, exerciseMinutes: Int? = nil, stepCount: Int? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.moodScore = max(1, min(5, moodScore)) // Clamp between 1-5
        self.notes = notes
        self.activities = activities
        self.sleepHours = sleepHours
        self.exerciseMinutes = exerciseMinutes
        self.stepCount = stepCount
    }
}

// Sample data for previews
extension MoodEntry {
    static var sampleEntries: [MoodEntry] {
        [
            MoodEntry(
                timestamp: Date().addingTimeInterval(-86400 * 7),
                moodScore: 4,
                notes: "Had a great day at work. Feeling productive!",
                activities: ["Work", "Exercise", "Friends"]
            ),
            MoodEntry(
                timestamp: Date().addingTimeInterval(-86400 * 6),
                moodScore: 3,
                notes: "Feeling okay, a bit tired.",
                activities: ["Work", "Netflix"]
            ),
            MoodEntry(
                timestamp: Date().addingTimeInterval(-86400 * 5),
                moodScore: 5,
                notes: "Amazing weekend! Spent time with loved ones.",
                activities: ["Family", "Outdoor", "Relaxing"]
            ),
            MoodEntry(
                timestamp: Date().addingTimeInterval(-86400 * 4),
                moodScore: 2,
                notes: "Rough day. Feeling stressed about deadlines.",
                activities: ["Work", "Stress"]
            ),
            MoodEntry(
                timestamp: Date().addingTimeInterval(-86400 * 3),
                moodScore: 4,
                notes: "Better today. Morning run really helped!",
                activities: ["Exercise", "Work", "Reading"]
            ),
            MoodEntry(
                timestamp: Date().addingTimeInterval(-86400 * 2),
                moodScore: 4,
                notes: "Good progress on my project.",
                activities: ["Work", "Creative"]
            ),
            MoodEntry(
                timestamp: Date().addingTimeInterval(-86400 * 1),
                moodScore: 3,
                notes: "Feeling neutral. Just going through the motions.",
                activities: ["Work", "Home"]
            ),
            MoodEntry(
                timestamp: Date(),
                moodScore: 5,
                notes: "Excited about the new app I'm building!",
                activities: ["Coding", "Creative", "Learning"]
            )
        ]
    }
    
    // PREDICTIVE DEMO DATA - 14 days with clear patterns for predictions
    static var predictiveSampleData: [MoodEntry] {
        let now = Date()
        
        return [
            // WEEK 1
            // Monday (2 weeks ago) - BAD (pattern: Mondays are tough)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -14, to: now)!,
                moodScore: 2,
                notes: "Ugh, Monday again. Already stressed about the week ahead.",
                activities: ["Work", "Stress"],
                sleepHours: 6.2,
                exerciseMinutes: 0,
                stepCount: 3200
            ),
            // Tuesday (13 days ago) - GOOD (with exercise)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -13, to: now)!,
                moodScore: 4,
                notes: "Morning workout really helped! Feeling energized.",
                activities: ["Exercise", "Work"],
                sleepHours: 7.8,
                exerciseMinutes: 45,
                stepCount: 8900
            ),
            // Wednesday (12 days ago) - OK
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -12, to: now)!,
                moodScore: 3,
                notes: "Pretty normal day. Nothing special.",
                activities: ["Work"],
                sleepHours: 7.3,
                exerciseMinutes: 0,
                stepCount: 5400
            ),
            // Thursday (11 days ago) - GOOD (with exercise + social)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -11, to: now)!,
                moodScore: 4,
                notes: "Had lunch with friends and hit the gym. Great day!",
                activities: ["Exercise", "Social", "Work"],
                sleepHours: 8.1,
                exerciseMinutes: 50,
                stepCount: 9200
            ),
            // Friday (10 days ago) - GOOD
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -10, to: now)!,
                moodScore: 4,
                notes: "TGIF! Excited for the weekend.",
                activities: ["Work", "Social"],
                sleepHours: 7.5,
                exerciseMinutes: 0,
                stepCount: 6700
            ),
            // Saturday (9 days ago) - AMAZING (weekend + social)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -9, to: now)!,
                moodScore: 5,
                notes: "Perfect weekend day! Brunch with friends and relaxing.",
                activities: ["Social", "Outdoor", "Relaxing"],
                sleepHours: 9.2,
                exerciseMinutes: 0,
                stepCount: 7800
            ),
            // Sunday (8 days ago) - OK (Sunday scaries start)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -8, to: now)!,
                moodScore: 3,
                notes: "Sunday evening anxiety kicking in. Dreading Monday.",
                activities: ["Home", "Reading"],
                sleepHours: 7.9,
                exerciseMinutes: 0,
                stepCount: 4200
            ),
            
            // WEEK 2
            // Monday (7 days ago) - BAD (pattern confirmed: Mondays suck + poor sleep)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -7, to: now)!,
                moodScore: 2,
                notes: "Another rough Monday. So much work piled up. Feeling overwhelmed.",
                activities: ["Work", "Stress"],
                sleepHours: 5.8,
                exerciseMinutes: 0,
                stepCount: 2900
            ),
            // Tuesday (6 days ago) - GOOD (exercise + good sleep pattern)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -6, to: now)!,
                moodScore: 5,
                notes: "Woke up early and went to the gym! Feeling amazing!",
                activities: ["Exercise", "Work"],
                sleepHours: 8.3,
                exerciseMinutes: 60,
                stepCount: 10200
            ),
            // Wednesday (5 days ago) - MEH (no exercise, just work, poor sleep)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -5, to: now)!,
                moodScore: 3,
                notes: "Skipped gym today. Feeling blah.",
                activities: ["Work"],
                sleepHours: 6.5,
                exerciseMinutes: 0,
                stepCount: 4800
            ),
            // Thursday (4 days ago) - GOOD (exercise + social + good sleep)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -4, to: now)!,
                moodScore: 4,
                notes: "Gym this morning then dinner with friends. Good vibes!",
                activities: ["Exercise", "Social", "Work"],
                sleepHours: 8.0,
                exerciseMinutes: 40,
                stepCount: 9500
            ),
            // Friday (3 days ago) - GREAT
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -3, to: now)!,
                moodScore: 5,
                notes: "Friday energy! Productive week, ready to relax.",
                activities: ["Work", "Social"],
                sleepHours: 7.7,
                exerciseMinutes: 0,
                stepCount: 7200
            ),
            // Saturday (2 days ago) - AMAZING (weekend pattern + exercise + great sleep)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: now)!,
                moodScore: 5,
                notes: "Best day! Long hike with friends and beautiful weather.",
                activities: ["Exercise", "Social", "Outdoor"],
                sleepHours: 9.5,
                exerciseMinutes: 120,
                stepCount: 15000
            ),
            // Sunday (yesterday) - OK (Sunday scaries again)
            MoodEntry(
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: now)!,
                moodScore: 3,
                notes: "Sunday evening dread. Not ready for Monday tomorrow.",
                activities: ["Home", "Relaxing"],
                sleepHours: 7.4,
                exerciseMinutes: 0,
                stepCount: 5100
            ),
            // Today (varies)
            MoodEntry(
                timestamp: now,
                moodScore: 4,
                notes: "Feeling optimistic! This app is helping me see patterns.",
                activities: ["Reading", "Learning"],
                sleepHours: 8.1,
                exerciseMinutes: 30,
                stepCount: 6800
            )
        ]
    }
}

