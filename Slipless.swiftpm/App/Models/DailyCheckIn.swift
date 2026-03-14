import Foundation
import SwiftData

@Model
final class DailyCheckIn {
    var id: UUID
    var date: Date
    var feelingRawValue: String
    var urgeLevelRawValue: String
    var statusRawValue: String
    
    // Relationship
    var habit: HabitProfile?
    
    init(id: UUID = UUID(), 
         date: Date = Date(), 
         feeling: CheckInFeeling, 
         urgeLevel: CheckInUrgeLevel, 
         status: CheckInStatus) {
        self.id = id
        // Normalize to start of day
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: date)
        self.feelingRawValue = feeling.rawValue
        self.urgeLevelRawValue = urgeLevel.rawValue
        self.statusRawValue = status.rawValue
    }
    
    var feeling: CheckInFeeling {
        get { CheckInFeeling(rawValue: feelingRawValue) ?? .okay }
        set { feelingRawValue = newValue.rawValue }
    }
    
    var urgeLevel: CheckInUrgeLevel {
        get { CheckInUrgeLevel(rawValue: urgeLevelRawValue) ?? .none }
        set { urgeLevelRawValue = newValue.rawValue }
    }
    
    var status: CheckInStatus {
        get { CheckInStatus(rawValue: statusRawValue) ?? .onTrack }
        set { statusRawValue = newValue.rawValue }
    }
}

enum CheckInFeeling: String, Codable {
    case easy
    case okay
    case hard
}

enum CheckInUrgeLevel: String, Codable {
    case none
    case little
    case yes
}

enum CheckInStatus: String, Codable {
    case onTrack
    case slipped
}
