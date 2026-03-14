import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [HabitProfile]
    @Environment(SettingsManager.self) private var settings
    @Binding var selectedTab: Int

    @State private var showingUrgeSheet = false
    @State private var showingSlipSheet = false
    @State private var showingCheckInSheet = false
    
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
                                .foregroundColor(.gray)
                            
                            // Check-In Card
                            if !hasCheckedInToday(habit: habit) {
                                checkInCard
                            }
                            
                            // Quick Actions
                            quickActions
                            
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
                UrgeResetView(habit: habit!)
            }
            .sheet(isPresented: $showingSlipSheet) {
                SlipLogView(habit: habit!)
            }
            .sheet(isPresented: $showingCheckInSheet) {
                DailyCheckInView(habit: habit!)
            }
            .onOpenURL { url in
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
            
            Text(label)
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    var checkInCard: some View {
        Button(action: { showingCheckInSheet = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Check-in")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Take a moment to log how you're feeling today.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
    
    var quickActions: some View {
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
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
            }
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
                }
                
                Text(primaryReason)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .italic()
                
                if let note = habit.noteToSelf, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
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
                .foregroundColor(.gray)
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
    }
    
    func hasCheckedInToday(habit: HabitProfile) -> Bool {
        let calendar = Calendar.current
        return habit.checkIns.contains(where: { calendar.isDateInToday($0.date) })
    }
}
