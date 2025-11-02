//
//  HistoryView.swift
//  Genuity AI
//
//  Historical mood entries
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    
    var filteredEntries: [MoodEntry] {
        if searchText.isEmpty {
            return dataManager.entries
        } else {
            return dataManager.entries.filter { entry in
                entry.notes.localizedCaseInsensitiveContains(searchText) ||
                entry.activities.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if dataManager.entries.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            HistoryRow(entry: entry)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .searchable(text: $searchText, prompt: "Search entries...")
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !dataManager.entries.isEmpty {
                    EditButton()
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            
            Text("Start Your Journey")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your mood entries will appear here after your first check-in.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "1.circle.fill")
                        .foregroundColor(.purple)
                    Text("Go to Chat tab")
                        .font(.subheadline)
                }
                HStack {
                    Image(systemName: "2.circle.fill")
                        .foregroundColor(.purple)
                    Text("Tell me how you're feeling")
                        .font(.subheadline)
                }
                HStack {
                    Image(systemName: "3.circle.fill")
                        .foregroundColor(.purple)
                    Text("Come back here to see your entry")
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding(.vertical, 60)
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        dataManager.deleteEntries(at: offsets)
    }
}

struct HistoryRow: View {
    let entry: MoodEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.moodEmoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.timestamp, style: .date)
                        .font(.headline)
                    
                    Text(entry.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                MoodScoreIndicator(score: entry.moodScore)
            }
            
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if !entry.activities.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.activities, id: \.self) { activity in
                            Text(activity)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct MoodScoreIndicator: View {
    let score: Int
    
    var color: Color {
        switch score {
        case 1...2: return .red
        case 3: return .orange
        case 4: return .yellow
        case 5: return .green
        default: return .gray
        }
    }
    
    var body: some View {
        Text("\(score)")
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(color)
            .clipShape(Circle())
    }
}

#Preview {
    HistoryView()
        .environmentObject(DataManager())
}

