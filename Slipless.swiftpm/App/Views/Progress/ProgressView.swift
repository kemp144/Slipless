import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query private var habits: [HabitProfile]
    var habit: HabitProfile? { habits.first }
    
    struct Milestone: Identifiable {
        let id = UUID()
        let days: Int
        let title: String
        var isUnlocked: Bool
    }
    
    var milestones: [Milestone] {
        guard let habit = habit else { return [] }
        let currentDays = Calendar.current.dateComponents([.day], from: habit.lastSlipDate ?? habit.startDate, to: Date()).day ?? 0
        
        let targets = [1, 3, 7, 14, 30, 60, 90, 180, 365]
        return targets.map { target in
            Milestone(days: target, title: "\(target) Days", isUnlocked: currentDays >= target)
        }
    }
    
    var body: some View {
        NavigationStack {
            if let habit = habit {
                let effectiveStart = habit.lastSlipDate ?? habit.startDate
                ScrollView {
                    VStack(spacing: 20) {
                        // Calendar Heatmap
                        CalendarHeatmapView(habit: habit)
                            .padding(.horizontal)
                        
                        // Recovery Trends & Stats
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recovery Trends")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                if let avgTime = ProgressAnalytics.calculateAverageTimeBetweenSlips(slips: habit.slips, startDate: effectiveStart) {
                                    StatRow(title: "Average Time Between Slips", value: formatTimeInterval(avgTime))
                                }
                                
                                if let longestGap = ProgressAnalytics.calculateLongestGap(slips: habit.slips, startDate: effectiveStart) {
                                    StatRow(title: "Longest Streak", value: formatTimeInterval(longestGap))
                                }
                                
                                if let improvementText = ProgressAnalytics.generateImprovementText(slips: habit.slips, startDate: effectiveStart) {
                                    Divider()
                                    HStack {
                                        Text(improvementText)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.vertical, 8)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Pattern Insights
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pattern Insights")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                if let triggerInsight = ProgressAnalytics.determineMostCommonTrigger(slips: habit.slips) {
                                    InsightRow(icon: "lightbulb.fill", color: .yellow, text: triggerInsight)
                                }
                                
                                let events = habit.slips.map { $0.date } + habit.urges.map { $0.date }
                                if let timeInsight = ProgressAnalytics.determineDifficultTimeOfDay(events: events) {
                                    InsightRow(icon: "clock.fill", color: .blue, text: timeInsight)
                                }
                                
                                if habit.slips.isEmpty && habit.urges.isEmpty {
                                    Text("Not enough data for insights yet.")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Milestones
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Milestones")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                ForEach(milestones) { milestone in
                                    HStack {
                                        Image(systemName: milestone.isUnlocked ? "medal.fill" : "medal")
                                            .foregroundColor(milestone.isUnlocked ? .yellow : .gray)
                                            .frame(width: 24)
                                        
                                        Text(milestone.title)
                                            .fontWeight(milestone.isUnlocked ? .bold : .regular)
                                            .foregroundColor(milestone.isUnlocked ? .primary : .gray)
                                        
                                        Spacer()
                                        
                                        if milestone.isUnlocked {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                    
                                    if milestone.id != milestones.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Progress")
                .background(Color(.systemGroupedBackground))
            } else {
                ContentUnavailableView("No Data", systemImage: "chart.bar")
            }
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        return formatter.string(from: interval) ?? "0 days"
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}

struct InsightRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}
