import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var settings = SettingsManager()
    
    var body: some View {
        ZStack {
            AppWallpaperView()

            Group {
                if settings.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
        }
        .environment(settings)
        .preferredColorScheme(.dark)
    }
}
