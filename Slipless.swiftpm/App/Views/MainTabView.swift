import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            ProgressView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(1)

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.fill") }
                .tag(2)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .accentColor(.white)
    }
}
