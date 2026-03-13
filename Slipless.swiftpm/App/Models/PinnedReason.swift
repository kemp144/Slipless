import Foundation
import SwiftData

@Model
final class PinnedReason {
    var id: UUID
    var text: String
    var icon: String? // SF Symbol name
    
    // Relationship
    var habit: HabitProfile?
    
    init(id: UUID = UUID(), text: String, icon: String? = nil) {
        self.id = id
        self.text = text
        self.icon = icon
    }
}
