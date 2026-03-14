import SwiftUI
import SwiftData
import UIKit

@main
struct SliplessApp: App {
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            HabitProfile.self,
            SlipEvent.self,
            UrgeEvent.self,
            PinnedReason.self,
            DailyCheckIn.self
        ])
    }
}
