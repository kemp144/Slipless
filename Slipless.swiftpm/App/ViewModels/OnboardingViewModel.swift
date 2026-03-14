import Foundation
import SwiftData
import SwiftUI

@Observable
class OnboardingViewModel {
    var step = 0
    var selectedPreset: HabitPreset?
    var customName = ""
    var selectedMode: HabitMode = .quit
    var startDate = Date()
    var lastSlipDate = Date()
    var moneySavedPerDay: Double?
    var timeSavedPerDay: Int?
    var selectedReasons: [String] = []
    var primaryReasonText: String = ""
    var noteToSelf: String = ""
    
    // Config
    let currencyCode = Locale.current.currency?.identifier ?? "USD"
    
    var isValidHabitName: Bool {
        if let preset = selectedPreset, preset.id != "custom" {
            return true
        }
        return !customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func saveHabit(context: ModelContext, settings: SettingsManager) {
        let name = (selectedPreset?.id == "custom" ? customName : selectedPreset?.name) ?? "Habit"
        
        let habit = HabitProfile(
            name: name,
            mode: selectedMode,
            startDate: startDate,
            moneySavedPerDay: moneySavedPerDay,
            timeSavedPerDay: timeSavedPerDay,
            currencyCode: currencyCode,
            primaryReasonText: primaryReasonText.isEmpty ? nil : primaryReasonText,
            noteToSelf: noteToSelf.isEmpty ? nil : noteToSelf
        )
        
        // Add reasons
        for reasonText in selectedReasons {
            let reason = PinnedReason(text: reasonText)
            habit.reasons.append(reason)
        }
        
        // If quit mode, set last slip to start date initially if not specified separately (simplified for V1)
        // Or if the user picked a specific slip date in step 3
        habit.lastSlipDate = lastSlipDate
        
        context.insert(habit)
        
        // Mark onboarding complete
        settings.hasCompletedOnboarding = true
    }
}
