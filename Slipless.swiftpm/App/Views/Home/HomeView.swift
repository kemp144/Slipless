import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [HabitProfile]
    @Environment(SettingsManager.self) private var settings
    
    @State private var showingUrgeSheet = false
    @State private var showingSlipSheet = false
    @State private var pledgeCompleted = false // In a real app, store this persistently per day
    
    var habit: HabitProfile? { habits.first }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let habit = habit {
                    ScrollView {
                        VStack(spacing: 30) {
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
                            
                            // Buttons
                            VStack(spacing: 16) {
                                Button(action: { showingUrgeSheet = true }) {
                                    Text("I have an urge")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(16)
                                }
                                
                                Button(action: { showingSlipSheet = true }) {
                                    Text("Log a slip")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                            
                            // Pledge Card
                            pledgeCard
                            
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
            .onAppear {
                checkPledgeStatus()
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
    
    var pledgeCard: some View {
        Button(action: {
            withAnimation {
                pledgeCompleted.toggle()
                if pledgeCompleted {
                    UserDefaults.standard.set(Date(), forKey: "lastPledgeDate")
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
        }) {
            HStack {
                Image(systemName: pledgeCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(pledgeCompleted ? .green : .gray)
                
                VStack(alignment: .leading) {
                    Text("Daily Pledge")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Just for today, I am in control.")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.08))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
    
    func statsGrid(habit: HabitProfile) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            // Money Saved
            if let dailyCost = habit.moneySavedPerDay, dailyCost > 0 {
                let days = Calendar.current.dateComponents([.day], from: habit.startDate, to: Date()).day ?? 0
                let saved = Double(days) * dailyCost
                statCard(title: "Money Saved", value: saved.formatted(.currency(code: habit.currencyCode)))
            }
            
            // Urges Survived
            let urges = habit.urges.count
            statCard(title: "Urges Won", value: "\(urges)")
            
            // Best Streak (Simplified: just show current for V1 or calculate if we had history)
            // For V1 MVP, maybe just show "Slips"
            statCard(title: "Total Slips", value: "\(habit.slips.count)")
        }
        .padding(.horizontal)
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
    
    func checkPledgeStatus() {
        if let lastDate = UserDefaults.standard.object(forKey: "lastPledgeDate") as? Date {
            if Calendar.current.isDateInToday(lastDate) {
                pledgeCompleted = true
            } else {
                pledgeCompleted = false
            }
        }
    }
}
