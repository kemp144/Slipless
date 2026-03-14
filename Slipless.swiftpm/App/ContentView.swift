import SwiftUI
import SwiftData

public struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var settings = SettingsManager()
    @Query(sort: \HabitProfile.createdDate, order: .reverse) private var habits: [HabitProfile]

    public init() {}

    private var shouldShowMainExperience: Bool {
        settings.hasCompletedOnboarding && !habits.isEmpty
    }
    
    public var body: some View {
        ZStack {
            AppWallpaperView()

            Group {
                if shouldShowMainExperience {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
        }
        .environment(settings)
        .preferredColorScheme(.dark)
        .onAppear {
            cleanupDuplicateHabitsIfNeeded()

            if settings.hasCompletedOnboarding && habits.isEmpty {
                settings.hasCompletedOnboarding = false
            }
        }
    }

    private func cleanupDuplicateHabitsIfNeeded() {
        guard habits.count > 1 else { return }

        let sortedByPriority = habits.sorted { lhs, rhs in
            habitPriority(lhs) > habitPriority(rhs)
        }

        guard let habitToKeep = sortedByPriority.first else { return }

        for habit in habits where habit.id != habitToKeep.id {
            modelContext.delete(habit)
        }

        try? modelContext.save()
    }

    private func habitPriority(_ habit: HabitProfile) -> Int {
        let streakDays = max(0, Calendar.current.dateComponents([.day], from: habit.lastSlipDate ?? habit.startDate, to: Date()).day ?? 0)

        var score = 0
        score += streakDays * 3
        score += habit.checkIns.count * 20
        score += habit.urges.count * 12
        score += habit.slips.count * 10
        score += habit.reasons.count * 8
        score += habit.moneySavedPerDay != nil ? 40 : 0
        score += habit.timeSavedPerDay != nil ? 40 : 0
        score += (habit.primaryReasonText?.isEmpty == false) ? 25 : 0
        score += (habit.noteToSelf?.isEmpty == false) ? 15 : 0
        return score
    }
}
