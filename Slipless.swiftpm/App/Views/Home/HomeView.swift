import SwiftUI
import SwiftData
import UIKit

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HabitProfile.createdDate, order: .reverse) private var habits: [HabitProfile]
    @Environment(SettingsManager.self) private var settings
    @Binding var selectedTab: Int

    @State private var showingUrgeSheet = false
    @State private var showingSlipSheet = false
    @State private var showingCheckInSheet = false
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
    var habit: HabitProfile? { habits.first }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                if let habit = habit {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Hero Counter
                            TimelineView(.periodic(from: .now, by: 60)) { context in
                                streakCounter(habit: habit, date: context.date)
                            }
                            .padding(.top, 40)
                            
                            // Habit Name
                            Text(settings.isStealthModeEnabled ? "On Track" : habit.name)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.appSecondaryText)
                                .appTextShadow()
                            
                            // Check-In Card
                            if !hasCheckedInToday(habit: habit) {
                                checkInCard
                            }
                            
                            // Quick Actions
                            quickActions(habit: habit)
                            
                            // Motivation / Why I Started
                            motivationCard(habit: habit)
                            
                            // Stats Summary
                            statsGrid(habit: habit)
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView("No Habit Found", systemImage: "exclamationmark.triangle")
                }
            }
            .sheet(isPresented: $showingUrgeSheet) {
                if let habit = habit {
                    UrgeResetView(habit: habit)
                } else {
                    ContentUnavailableView("No Habit Found", systemImage: "exclamationmark.triangle")
                }
            }
            .sheet(isPresented: $showingSlipSheet) {
                if let habit = habit {
                    SlipLogView(habit: habit)
                } else {
                    ContentUnavailableView("No Habit Found", systemImage: "exclamationmark.triangle")
                }
            }
            .sheet(isPresented: $showingCheckInSheet) {
                if let habit = habit {
                    DailyCheckInView(habit: habit)
                } else {
                    ContentUnavailableView("No Habit Found", systemImage: "exclamationmark.triangle")
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: shareItems)
            }
            .onOpenURL { url in
                guard habit != nil else { return }
                if url.host == "urge" {
                    selectedTab = 0
                    showingUrgeSheet = true
                } else if url.host == "slip" {
                    selectedTab = 0
                    showingSlipSheet = true
                } else if url.host == "checkin" {
                    selectedTab = 0
                    showingCheckInSheet = true
                }
            }
        }
    }
    
    func streakCounter(habit: HabitProfile, date: Date) -> some View {
        let (count, label) = TimeFormatter.streakString(from: habit.lastSlipDate ?? habit.startDate)
        
        return VStack(spacing: 0) {
            Text(count)
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .appTextShadow(opacity: 0.42, radius: 4, y: 2)
            
            Text(label)
                .font(.title2)
                .foregroundColor(.appSecondaryText)
                .appTextShadow()
        }
    }
    
    var checkInCard: some View {
        Button(action: { showingCheckInSheet = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Check-in")
                        .font(.headline)
                        .foregroundColor(.appPrimaryText)
                        .appTextShadow()
                    Text("Take a moment to log how you're feeling today.")
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.appSecondaryText)
            }
            .padding()
            .appPanelStyle()
        }
        .buttonStyle(.plain)
    }
    
    func quickActions(habit: HabitProfile) -> some View {
        VStack(spacing: 16) {
            Button(action: { showingUrgeSheet = true }) {
                Text(settings.isStealthModeEnabled ? "Need Support" : "I have an urge")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
            }
            
            Button(action: { showingSlipSheet = true }) {
                Text(settings.isStealthModeEnabled ? "Log Event" : "Log a slip")
                    .font(.subheadline)
                    .foregroundColor(.appSecondaryText)
                    .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .appPanelStyle()
            }

            Button(action: { presentAchievementShare(for: habit) }) {
                HStack(spacing: 14) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundColor(.appPrimaryText)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Share Progress")
                            .font(.headline)
                            .foregroundColor(.appPrimaryText)
                            .appTextShadow()

                        Text(shareAchievementSubtitle(for: habit))
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryText)
                            .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.appSecondaryText)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .appPanelStyle()
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    func motivationCard(habit: HabitProfile) -> some View {
        if let primaryReason = habit.primaryReasonText, !primaryReason.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Why I Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .appTextShadow()
                }
                
                Text(primaryReason)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .italic()
                    .appTextShadow()
                
                if let note = habit.noteToSelf, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryText)
                        .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .appPanelStyle()
        }
    }
    
    func statsGrid(habit: HabitProfile) -> some View {
        let fromDate = habit.lastSlipDate ?? habit.startDate
        let days = Calendar.current.dateComponents([.day], from: fromDate, to: Date()).day ?? 0

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            // Money Saved
            if let dailyCost = habit.moneySavedPerDay, dailyCost > 0 {
                let saved = Double(days) * dailyCost
                statCard(title: "Money Saved", value: saved.formatted(.currency(code: habit.currencyCode)))
            }

            // Time Saved
            if let dailyMinutes = habit.timeSavedPerDay, dailyMinutes > 0 {
                let totalMinutes = days * dailyMinutes
                statCard(title: "Time Saved", value: formatMinutes(totalMinutes))
            }

            // Urges Survived
            statCard(title: "Urges Won", value: "\(habit.urges.filter { $0.outcome == "passed" }.count)")

            Button(action: { selectedTab = 2 }) {
                statCard(title: "Total Slips", value: "\(habit.slips.count)")
            }
            .buttonStyle(.plain)
        }
    }
    
    func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.appMutedText)
                .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.appPrimaryText)
                .appTextShadow()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .appCardStyle()
    }
    
    func hasCheckedInToday(habit: HabitProfile) -> Bool {
        let calendar = Calendar.current
        return habit.checkIns.contains(where: { calendar.isDateInToday($0.date) })
    }

    func shareAchievementTitle(for habit: HabitProfile) -> String {
        let (count, label) = TimeFormatter.streakString(from: habit.lastSlipDate ?? habit.startDate)
        let streakText = "\(count) \(label)"

        if settings.isStealthModeEnabled {
            return "\(streakText) on track"
        }

        return "\(habit.name): \(streakText) strong"
    }

    func shareAchievementSubtitle(for habit: HabitProfile) -> String {
        let urgesWon = habit.urges.filter { $0.outcome == "passed" }.count
        return "\(shareAchievementTitle(for: habit)) • \(urgesWon) urges won"
    }

    func shareAchievementText(for habit: HabitProfile) -> String {
        let (count, label) = TimeFormatter.streakString(from: habit.lastSlipDate ?? habit.startDate)
        let urgesWon = habit.urges.filter { $0.outcome == "passed" }.count
        let slipsLogged = habit.slips.count
        let streakDays = max(0, Calendar.current.dateComponents([.day], from: habit.lastSlipDate ?? habit.startDate, to: Date()).day ?? 0)

        var lines: [String] = []
        if settings.isStealthModeEnabled {
            lines.append("I'm \(count) \(label.lowercased()) on track with Slipless.")
        } else {
            lines.append("I've stayed away from \(habit.name.lowercased()) for \(count) \(label.lowercased()) with Slipless.")
        }

        lines.append("")
        lines.append("Stats:")
        lines.append("• Current streak: \(TimeFormatter.detailedStreak(from: habit.lastSlipDate ?? habit.startDate))")
        lines.append("• Urges won: \(urgesWon)")
        lines.append("• Slips logged: \(slipsLogged)")

        if let dailyMinutes = habit.timeSavedPerDay, dailyMinutes > 0 {
            lines.append("• Time reclaimed: \(formatMinutes(streakDays * dailyMinutes))")
        }

        if let dailyCost = habit.moneySavedPerDay, dailyCost > 0 {
            let saved = Double(streakDays) * dailyCost
            lines.append("• Money saved: \(saved.formatted(.currency(code: habit.currencyCode)))")
        }

        lines.append("")
        lines.append("Built with Slipless.")

        return lines.joined(separator: "\n")
    }

    func presentAchievementShare(for habit: HabitProfile) {
        guard let image = renderAchievementImage(for: habit) else { return }
        shareItems = [image]
        showingShareSheet = true
    }

    func renderAchievementImage(for habit: HabitProfile) -> UIImage? {
        let renderer = ImageRenderer(
            content: ShareAchievementCardView(
                title: shareAchievementTitle(for: habit),
                streakValue: TimeFormatter.streakString(from: habit.lastSlipDate ?? habit.startDate).0,
                streakLabel: TimeFormatter.streakString(from: habit.lastSlipDate ?? habit.startDate).1,
                habitName: settings.isStealthModeEnabled ? "On Track" : habit.name,
                stats: shareAchievementStats(for: habit)
            )
        )

        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    func shareAchievementStats(for habit: HabitProfile) -> [(String, String)] {
        let streakDays = max(0, Calendar.current.dateComponents([.day], from: habit.lastSlipDate ?? habit.startDate, to: Date()).day ?? 0)
        let urgesWon = habit.urges.filter { $0.outcome == "passed" }.count
        let slipsLogged = habit.slips.count

        var stats: [(String, String)] = [
            ("Current streak", TimeFormatter.detailedStreak(from: habit.lastSlipDate ?? habit.startDate)),
            ("Urges won", "\(urgesWon)"),
            ("Slips logged", "\(slipsLogged)")
        ]

        if let dailyMinutes = habit.timeSavedPerDay, dailyMinutes > 0 {
            stats.append(("Time reclaimed", formatMinutes(streakDays * dailyMinutes)))
        }

        if let dailyCost = habit.moneySavedPerDay, dailyCost > 0 {
            let saved = Double(streakDays) * dailyCost
            stats.append(("Money saved", saved.formatted(.currency(code: habit.currencyCode))))
        }

        return Array(stats.prefix(4))
    }
}

private struct ShareAchievementCardView: View {
    let title: String
    let streakValue: String
    let streakLabel: String
    let habitName: String
    let stats: [(String, String)]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.11, blue: 0.20),
                            Color(red: 0.07, green: 0.23, blue: 0.30),
                            Color(red: 0.14, green: 0.18, blue: 0.38)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.06),
                    Color.clear,
                    Color.white.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Slipless")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.92))

                        Text(title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text(habitName)
                            .font(.system(size: 19, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.82))
                    }

                    Spacer()

                    Text("PROGRESS")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.78))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.10))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Current streak")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.72))

                    HStack(alignment: .bottom, spacing: 10) {
                        Text(streakValue)
                            .font(.system(size: 84, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text(streakLabel)
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.88))
                            .padding(.bottom, 14)
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.20))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .cornerRadius(28)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Key stats")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.90))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(stat.0)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.70))

                                Text(stat.1)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.72)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(18)
                            .background(Color.white.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
                            )
                            .cornerRadius(20)
                        }
                    }
                }

                Text("Take it one day at a time.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.88))
                    .padding(.top, 2)
            }
            .padding(28)
        }
        .frame(width: 1080, height: 1010)
    }
}
