//
//  AccountabilityView.swift
//  Genuity AI
//
//  Follow-up on prevention plans (Did you actually do it?)
//

import SwiftUI

struct AccountabilityFollowUpView: View {
    let check: AccountabilityCheck
    @Binding var isPresented: Bool
    @State private var stepCompletions: [Bool]
    @State private var currentMood: Double = 3.0
    
    var onComplete: (AccountabilityCheck) -> Void
    
    init(check: AccountabilityCheck, isPresented: Binding<Bool>, onComplete: @escaping (AccountabilityCheck) -> Void) {
        self.check = check
        self._isPresented = isPresented
        self.onComplete = onComplete
        self._stepCompletions = State(initialValue: Array(repeating: false, count: check.interventionPlan.steps.count))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    stepsChecklistView
                    moodCheckView
                    resultsView
                    submitButton
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("Did You Follow The Plan?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Yesterday I predicted your mood would be challenging")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var stepsChecklistView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Which steps did you complete?")
                .font(.headline)
            
            ForEach(Array(check.interventionPlan.steps.enumerated()), id: \.element.id) { index, step in
                Toggle(isOn: $stepCompletions[index]) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.action)
                            .font(.subheadline)
                        Text(step.timing)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(CheckboxToggleStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    private var moodCheckView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How was your actual mood yesterday?")
                .font(.headline)
            
            HStack(spacing: 20) {
                ForEach(1...5, id: \.self) { score in
                    moodButton(for: score)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .padding(.horizontal)
    }
    
    private func moodButton(for score: Int) -> some View {
        Button(action: { currentMood = Double(score) }) {
            VStack(spacing: 8) {
                Text(moodEmoji(score))
                    .font(.system(size: 40))
                Text("\(score)")
                    .font(.caption)
                    .fontWeight(Int(currentMood) == score ? .bold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Int(currentMood) == score ? Color.purple.opacity(0.2) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Int(currentMood) == score ? Color.purple : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var resultsView: some View {
        Group {
            if stepCompletions.contains(true) {
                let completed = stepCompletions.filter { $0 }.count
                let total = stepCompletions.count
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Impact Analysis", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Steps Completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(completed)/\(total)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Compliance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(Int(Double(completed)/Double(total) * 100))%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                        }
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    private var submitButton: some View {
        Button(action: submitFollowUp) {
            Text("Submit Follow-Up")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(16)
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
    
    private func submitFollowUp() {
        var updatedCheck = check
        updatedCheck.completed = true
        updatedCheck.actualMood = Int(currentMood)
        
        for (index, completed) in stepCompletions.enumerated() {
            updatedCheck.actualFollowThrough[index].completed = completed
        }
        
        onComplete(updatedCheck)
        isPresented = false
    }
    
    private func moodEmoji(_ score: Int) -> String {
        switch score {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "😐"
        }
    }
}

#Preview {
    AccountabilityFollowUpView(
        check: AccountabilityCheck(
            predictionId: UUID(),
            interventionPlan: InterventionPlan(
                steps: [
                    InterventionStep(timing: "Tonight", action: "Sleep early", reason: "Boosts mood"),
                    InterventionStep(timing: "Morning", action: "Exercise", reason: "Helps mood")
                ],
                predictedImprovement: 1.5
            ),
            scheduledDate: Date()
        ),
        isPresented: .constant(true),
        onComplete: { _ in }
    )
}

