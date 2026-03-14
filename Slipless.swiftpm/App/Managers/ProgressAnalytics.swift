import Foundation

struct ProgressAnalytics {
    
    // MARK: - Recovery Trends
    
    static func calculateAverageTimeBetweenSlips(slips: [SlipEvent], startDate: Date) -> TimeInterval? {
        let validSlips = slips.filter { $0.date >= startDate }
        guard !validSlips.isEmpty else { return nil }
        
        let sortedSlips = validSlips.sorted { $0.date < $1.date }
        var totalInterval: TimeInterval = 0
        var previousDate = startDate
        
        for slip in sortedSlips {
            let interval = slip.date.timeIntervalSince(previousDate)
            if interval > 0 {
                totalInterval += interval
            }
            previousDate = slip.date
        }
        
        // Add the current ongoing period (from last slip to now)
        let currentInterval = Date().timeIntervalSince(previousDate)
        if currentInterval > 0 {
            totalInterval += currentInterval
        }
        
        return totalInterval / Double(sortedSlips.count + 1)
    }
    
    static func calculateLongestGap(slips: [SlipEvent], startDate: Date) -> TimeInterval? {
        let validSlips = slips.filter { $0.date >= startDate }
        
        // If no slips yet, the longest gap IS the current streak from start to now
        if validSlips.isEmpty {
            return Date().timeIntervalSince(startDate)
        }
        
        let sortedSlips = validSlips.sorted { $0.date < $1.date }
        var longest: TimeInterval = 0
        var previousDate = startDate
        
        for slip in sortedSlips {
            let interval = slip.date.timeIntervalSince(previousDate)
            if interval > longest { longest = interval }
            previousDate = slip.date
        }
        
        let currentInterval = Date().timeIntervalSince(previousDate)
        if currentInterval > longest { longest = currentInterval }
        
        return longest
    }
    
    static func generateImprovementText(slips: [SlipEvent], startDate: Date) -> String? {
        let validSlips = slips.filter { $0.date >= startDate }
        guard validSlips.count >= 2 else { return nil }
        
        let sortedSlips = validSlips.sorted { $0.date > $1.date } // newest first
        let mostRecentSlip = sortedSlips[0]
        let previousSlip = sortedSlips[1]
        
        let mostRecentGap = mostRecentSlip.date.timeIntervalSince(previousSlip.date)
        let currentGap = Date().timeIntervalSince(mostRecentSlip.date)
        
        // Avoid dividing by zero or getting weird logic if two slips happened at the exact same second
        if mostRecentGap <= 0 { return "Progress still counts. You're building resilience." }
        
        if currentGap > mostRecentGap {
            return "Your current streak is longer than your previous one. Great job!"
        } else {
            return "Progress still counts. You're building resilience."
        }
    }
    
    // MARK: - Pattern Insights
    
    static func determineMostCommonTrigger(slips: [SlipEvent]) -> String? {
        let triggers = slips.compactMap { $0.trigger }.filter { !$0.isEmpty }
        guard !triggers.isEmpty else { return nil }
        
        var counts: [String: Int] = [:]
        for trigger in triggers {
            counts[trigger, default: 0] += 1
        }
        
        if let mostCommon = counts.max(by: { $0.value < $1.value }) {
            return "\"\(mostCommon.key)\" is a common trigger lately."
        }
        return nil
    }
    
    static func determineDifficultTimeOfDay(events: [Date]) -> String? {
        guard !events.isEmpty else { return nil }
        
        var hourCounts: [Int: Int] = [:]
        let calendar = Calendar.current
        for date in events {
            let hour = calendar.component(.hour, from: date)
            hourCounts[hour, default: 0] += 1
        }
        
        guard let mostCommonHour = hourCounts.max(by: { $0.value < $1.value })?.key else { return nil }
        
        let timeOfDay: String
        switch mostCommonHour {
        case 0..<6: timeOfDay = "Late nights"
        case 6..<12: timeOfDay = "Mornings"
        case 12..<18: timeOfDay = "Afternoons"
        case 18..<24: timeOfDay = "Evenings"
        default: timeOfDay = "Certain times"
        }
        
        return "\(timeOfDay) seem to be the hardest for you."
    }
    
    // MARK: - Export Summary
    
    static func generateExportSummaryText(profile: HabitProfile, isStealthMode: Bool) -> String {
        let title = isStealthMode ? "Progress Summary" : "\(profile.name) - Progress"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let startDateStr = formatter.string(from: profile.startDate)
        
        // Calculate Streak
        let latestLoggedSlipDate = profile.slips.max(by: { $0.date < $1.date })?.date
        let effectiveLastSlipDate = [profile.lastSlipDate, latestLoggedSlipDate]
            .compactMap { $0 }
            .max() ?? profile.startDate
        let currentStreakSeconds = Date().timeIntervalSince(effectiveLastSlipDate)
        let days = Int(currentStreakSeconds / 86400)
        
        var summary = "\(title)\n"
        summary += "Started: \(startDateStr)\n"
        summary += "Current Streak: \(days) days\n"
        summary += "Urges Survived: \(profile.urges.filter { $0.outcome == "passed" }.count)\n"
        summary += "Slips Logged: \(profile.slips.count)\n"
        
        if let timeSaved = profile.timeSavedPerDay, timeSaved > 0 {
            let totalTimeSaved = (timeSaved * days) / 60
            summary += "Time Reclaimed: ~\(totalTimeSaved) hours\n"
        }
        
        if let moneySaved = profile.moneySavedPerDay, moneySaved > 0 {
            let totalMoneySaved = String(format: "%.2f", moneySaved * Double(days))
            summary += "Money Saved: \(totalMoneySaved) \(profile.currencyCode)\n"
        }
        
        return summary
    }
}
