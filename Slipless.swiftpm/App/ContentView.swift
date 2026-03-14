import SwiftUI
import SwiftData

public struct ContentView: View {
    @State private var settings = SettingsManager()

    public init() {}
    
    public var body: some View {
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
