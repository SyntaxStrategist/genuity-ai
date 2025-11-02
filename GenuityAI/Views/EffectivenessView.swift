//
//  EffectivenessView.swift
//  Genuity AI
//
//  Proof that prevention works (or doesn't)
//

import SwiftUI
import Charts

struct EffectivenessView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if dataManager.effectivenessReports.isEmpty {
                        emptyStateView
                    } else {
                        // Overall Stats
                        overallStatsCard
                        
                        // Accuracy Chart
                        accuracyChartCard
                        
                        // Individual Reports
                        reportsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Effectiveness")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis.circle")
                .font(.system(size: 60))
                .foregroundColor(.purple.opacity(0.6))
            
            Text("No Data Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Complete accountability follow-ups to see if prevention plans actually work")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    private var overallStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Overall Performance", systemImage: "star.fill")
                .font(.headline)
                .foregroundColor(.purple)
            
            HStack(spacing: 24) {
                StatBox(
                    value: String(format: "%.0f%%", averageAccuracy * 100),
                    label: "Prediction Accuracy",
                    color: .blue
                )
                
                StatBox(
                    value: String(format: "+%.1f", averageImprovement),
                    label: "Avg Improvement",
                    color: .green
                )
                
                StatBox(
                    value: "\(successfulInterventions)/\(dataManager.effectivenessReports.count)",
                    label: "Worked",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    private var accuracyChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Prediction vs Reality", systemImage: "chart.xyaxis.line")
                .font(.headline)
            
            Chart {
                ForEach(dataManager.effectivenessReports) { report in
                    LineMark(
                        x: .value("Date", report.date),
                        y: .value("Mood", report.predictedMood)
                    )
                    .foregroundStyle(.purple.opacity(0.6))
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(
                        x: .value("Date", report.date),
                        y: .value("Mood", report.actualMood)
                    )
                    .foregroundStyle(.green)
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 1...5)
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.purple.opacity(0.6))
                        .frame(width: 8, height: 8)
                    Text("Predicted")
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("Actual")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
    
    private var reportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Individual Reports")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(dataManager.effectivenessReports.sorted(by: { $0.date > $1.date })) { report in
                EffectivenessReportCard(report: report)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var averageAccuracy: Double {
        guard !dataManager.effectivenessReports.isEmpty else { return 0 }
        let sum = dataManager.effectivenessReports.reduce(0.0) { $0 + $1.accuracy }
        return sum / Double(dataManager.effectivenessReports.count)
    }
    
    private var averageImprovement: Double {
        let improvements = dataManager.effectivenessReports.compactMap { $0.improvement }
        guard !improvements.isEmpty else { return 0 }
        return improvements.reduce(0, +) / Double(improvements.count)
    }
    
    private var successfulInterventions: Int {
        dataManager.effectivenessReports.filter { $0.wasEffective }.count
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EffectivenessReportCard: View {
    let report: EffectivenessReport
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(report.date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: report.wasEffective ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(report.wasEffective ? .green : .orange)
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Predicted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", report.predictedMood))
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Actual")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", report.actualMood))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(report.actualMood > report.predictedMood ? .green : .purple)
                }
                
                Spacer()
                
                if let improvement = report.improvement {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Impact")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%+.1f", improvement))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(improvement > 0 ? .green : .red)
                    }
                }
            }
            
            if report.interventionUsed {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.purple)
                    Text("Completed \(report.stepsCompleted)/\(report.totalSteps) prevention steps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    EffectivenessView(dataManager: DataManager())
}

