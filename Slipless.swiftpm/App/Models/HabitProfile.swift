import Foundation
import SwiftData

@Model
final class HabitProfile {
    var id: UUID
    var name: String
    var modeRawValue: String
    var startDate: Date
    var lastSlipDate: Date?
    var moneySavedPerDay: Double?
    var timeSavedPerDay: Int? // in minutes
    var currencyCode: String
    
    // New Motivation & Context Fields
    var primaryReasonText: String?
    var noteToSelf: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade) var reasons: [PinnedReason] = []
    @Relationship(deleteRule: .cascade) var slips: [SlipEvent] = []
    @Relationship(deleteRule: .cascade) var urges: [UrgeEvent] = []
    @Relationship(deleteRule: .cascade) var checkIns: [DailyCheckIn] = []
    
    var createdDate: Date
    
    init(id: UUID = UUID(),
         name: String,
         mode: HabitMode,
         startDate: Date = Date(),
         moneySavedPerDay: Double? = nil,
         timeSavedPerDay: Int? = nil,
         currencyCode: String = CurrencySupport.currentCurrencyCode,
         primaryReasonText: String? = nil,
         noteToSelf: String? = nil) {
        self.id = id
        self.name = name
        self.modeRawValue = mode.rawValue
        self.startDate = startDate
        self.moneySavedPerDay = moneySavedPerDay
        self.timeSavedPerDay = timeSavedPerDay
        self.currencyCode = currencyCode
        self.primaryReasonText = primaryReasonText
        self.noteToSelf = noteToSelf
        self.createdDate = Date()
    }
    
    var mode: HabitMode {
        get { HabitMode(rawValue: modeRawValue) ?? .quit }
        set { modeRawValue = newValue.rawValue }
    }
}

enum HabitMode: String, Codable {
    case quit
    case reduce
}
