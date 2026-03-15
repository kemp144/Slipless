import SwiftUI
import SwiftData
import LocalAuthentication

public struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var settings = SettingsManager()
    @Query(sort: \HabitProfile.createdDate, order: .reverse) private var habits: [HabitProfile]
    @State private var isAppLocked = false
    @State private var isAuthenticating = false

    public init() {}

    private var shouldShowMainExperience: Bool {
        settings.hasCompletedOnboarding && !habits.isEmpty
    }

    private var shouldObscureSensitiveContent: Bool {
        shouldShowMainExperience && settings.faceIDLockEnabled && (isAppLocked || isAuthenticating)
    }

    private var reminderSyncToken: String {
        let habit = habits.first
        return [
            settings.dailyReminderEnabled.description,
            String(settings.dailyReminderHour),
            String(settings.dailyReminderMinute),
            habit?.id.uuidString ?? "none",
            String(habit?.slips.count ?? 0),
            String(habit?.urges.count ?? 0)
        ].joined(separator: "|")
    }
    
    public var body: some View {
        ZStack {
            AppWallpaperView()
                .blur(radius: shouldObscureSensitiveContent ? 18 : 0)
                .animation(.easeInOut(duration: 0.18), value: shouldObscureSensitiveContent)

            Group {
                if shouldShowMainExperience {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .blur(radius: shouldObscureSensitiveContent ? 14 : 0)
            .allowsHitTesting(!shouldObscureSensitiveContent)
            .animation(.easeInOut(duration: 0.18), value: shouldObscureSensitiveContent)

            if shouldShowMainExperience && settings.faceIDLockEnabled && isAppLocked {
                AppLockOverlayView(isAuthenticating: isAuthenticating) {
                    Task {
                        await authenticateIfNeeded(forcePrompt: true)
                    }
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

            if shouldShowMainExperience && settings.faceIDLockEnabled {
                isAppLocked = true
                Task {
                    await authenticateIfNeeded(forcePrompt: false)
                }
            }
        }
        .task(id: reminderSyncToken) {
            await ReminderManager.syncReminders(for: habits.first, settings: settings)
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard shouldShowMainExperience else { return }

            switch newPhase {
            case .inactive, .background:
                if settings.faceIDLockEnabled {
                    isAppLocked = true
                }
            case .active:
                if settings.faceIDLockEnabled {
                    Task {
                        await authenticateIfNeeded(forcePrompt: false)
                    }
                }
            @unknown default:
                break
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
        let streakDays = habit.currentStreakDays

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

    @MainActor
    private func authenticateIfNeeded(forcePrompt: Bool) async {
        guard settings.faceIDLockEnabled, shouldShowMainExperience else {
            isAppLocked = false
            return
        }

        guard !isAuthenticating else { return }

        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            isAppLocked = false
            return
        }

        if !forcePrompt && !isAppLocked {
            return
        }

        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Unlock Slipless"
            )
            if success {
                isAppLocked = false
            }
        } catch {
            isAppLocked = true
        }
    }
}

private struct AppLockOverlayView: View {
    let isAuthenticating: Bool
    let unlockAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "faceid")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)

                Text("Slipless is locked")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)

                Text("Use Face ID or your device passcode to continue.")
                    .font(.subheadline)
                    .foregroundColor(.appSecondaryText)
                    .multilineTextAlignment(.center)

                Button(action: unlockAction) {
                    Text(isAuthenticating ? "Unlocking..." : "Unlock")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                }
                .disabled(isAuthenticating)
            }
            .padding(24)
            .frame(maxWidth: 320)
            .appPanelStyle(cornerRadius: 20)
            .padding(.horizontal, 24)
        }
    }
}
