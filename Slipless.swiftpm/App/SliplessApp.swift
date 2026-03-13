import SwiftUI
import SwiftData

@main
struct SliplessApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            HabitProfile.self,
            SlipEvent.self,
            UrgeEvent.self,
            PinnedReason.self
        ])
    }
}
