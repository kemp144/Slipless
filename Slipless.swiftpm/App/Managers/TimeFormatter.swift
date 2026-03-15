import Foundation

struct TimeFormatter {
    static func streakString(from date: Date) -> (String, String) {
        let diff = max(0, Date().timeIntervalSince(date))
        
        let days = Int(diff) / 86400
        let hours = (Int(diff) % 86400) / 3600
        let minutes = (Int(diff) % 3600) / 60
        
        if days > 0 {
            return ("\(days)", days == 1 ? "Day" : "Days")
        } else if hours > 0 {
            return ("\(hours)", hours == 1 ? "Hour" : "Hours")
        } else {
            return ("\(minutes)", minutes == 1 ? "Minute" : "Minutes")
        }
    }
    
    static func detailedStreak(from date: Date) -> String {
        let diff = max(0, Date().timeIntervalSince(date))
        
        let days = Int(diff) / 86400
        let hours = (Int(diff) % 86400) / 3600
        let minutes = (Int(diff) % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
}
