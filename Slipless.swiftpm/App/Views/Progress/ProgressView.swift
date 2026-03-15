import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query(sort: \HabitProfile.createdDate, order: .reverse) private var habits: [HabitProfile]
    var habit: HabitProfile? { habits.first }
    
    struct Milestone: Identifiable {
        let id = UUID()
        let days: Int
        let title: String
        let subtitle: String
        var isUnlocked: Bool
    }
    
    var milestones: [Milestone] {
        guard let habit = habit else { return [] }
        let currentDays = Calendar.current.dateComponents([.day], from: habit.lastSlipDate ?? habit.startDate, to: Date()).day ?? 0
        
        let targets = [1, 3, 7, 14, 30, 60, 90, 180, 365]
        return targets.map { target in
            let copy = milestoneCopy(for: target)
            return Milestone(days: target, title: copy.title, subtitle: copy.subtitle, isUnlocked: currentDays >= target)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                if let habit = habit {
                    let effectiveStart = habit.lastSlipDate ?? habit.startDate
                    ScrollView {
                        VStack(spacing: 20) {
                            CalendarHeatmapView(habit: habit)
                                .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recovery Trends")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .appTextShadow()

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
                                                .foregroundColor(.appSecondaryText)
                                                .padding(.vertical, 8)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .appCardStyle()
                                .padding(.horizontal)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Pattern Insights")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .appTextShadow()

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
                                            .foregroundColor(.appSecondaryText)
                                            .font(.subheadline)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .appCardStyle()
                                .padding(.horizontal)
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Milestones")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .appTextShadow()

                                VStack(spacing: 0) {
                                    ForEach(milestones) { milestone in
                                        HStack {
                                            Image(systemName: milestone.isUnlocked ? "medal.fill" : "medal")
                                                .foregroundColor(milestone.isUnlocked ? .yellow : .appMutedText)
                                                .frame(width: 24)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(milestone.title)
                                                    .fontWeight(milestone.isUnlocked ? .bold : .regular)
                                                    .foregroundColor(milestone.isUnlocked ? .appPrimaryText : .appSecondaryText)

                                                Text(milestone.subtitle)
                                                    .font(.caption)
                                                    .foregroundColor(.appSecondaryText)
                                            }

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
                                .appCardStyle()
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .navigationTitle("Progress")
                } else {
                    ContentUnavailableView("No Data", systemImage: "chart.bar")
                }
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

    private func milestoneCopy(for days: Int) -> (title: String, subtitle: String) {
        switch days {
        case 1:
            return ("First 24 Hours", "The hardest start is behind you.")
        case 3:
            return ("Three Days In", "You're building real momentum now.")
        case 7:
            return ("First Full Week", "A whole week of showing up for yourself.")
        case 14:
            return ("Two Weeks Strong", "Consistency is starting to feel familiar.")
        case 30:
            return ("30 Days Back In Control", "This is no longer just a restart.")
        case 60:
            return ("60 Days Of Progress", "Your new pattern is getting stronger.")
        case 90:
            return ("90 Days Clear", "Three months of proof that change is real.")
        case 180:
            return ("Half A Year Reclaimed", "You've carried this farther than most attempts go.")
        case 365:
            return ("One Year Reclaimed", "A full year of choosing your future.")
        default:
            return ("\(days) Days", "Progress that keeps compounding.")
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.appPrimaryText)
                .appTextShadow()
            Spacer()
            Text(value)
                .foregroundColor(.appSecondaryText)
                .fontWeight(.medium)
                .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
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
                .foregroundColor(.appPrimaryText)
                .appTextShadow()
        }
    }
}
