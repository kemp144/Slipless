import SwiftUI
import SwiftData

public struct ContentView: View {
    @State private var settings = SettingsManager()
    @Query private var habits: [HabitProfile]

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
            if settings.hasCompletedOnboarding && habits.isEmpty {
                settings.hasCompletedOnboarding = false
            }
        }
    }
}
