import Foundation
import SwiftData

@Model
final class SlipEvent {
    var id: UUID
    var date: Date
    var trigger: String?
    var intensity: Int // 1-5
    var note: String?
    
    // Relationship
    var habit: HabitProfile?
    
    init(id: UUID = UUID(), date: Date = Date(), trigger: String? = nil, intensity: Int = 3, note: String? = nil) {
        self.id = id
        self.date = date
        self.trigger = trigger
        self.intensity = intensity
        self.note = note
    }
}
