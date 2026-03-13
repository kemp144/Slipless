import Foundation
import SwiftData

@Model
final class UrgeEvent {
    var id: UUID
    var date: Date
    var duration: TimeInterval // usually 60s
    var outcome: String // "passed", "struggled"
    
    // Relationship
    var habit: HabitProfile?
    
    init(id: UUID = UUID(), date: Date = Date(), duration: TimeInterval = 60, outcome: String = "passed") {
        self.id = id
        self.date = date
        self.duration = duration
        self.outcome = outcome
    }
}
