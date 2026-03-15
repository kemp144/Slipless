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
    let currencyCode = CurrencySupport.currentCurrencyCode

    var currencyDisplay: String {
        CurrencySupport.currentCurrencyDisplay
    }

    var trimmedCustomName: String {
        customName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var resolvedHabitName: String {
        if selectedPreset?.id == "custom" {
            return trimmedCustomName.isEmpty ? "Habit" : trimmedCustomName
        }
        return selectedPreset?.name ?? "Habit"
    }
    
    var isValidHabitName: Bool {
        if let preset = selectedPreset, preset.id != "custom" {
            return true
        }
        return !trimmedCustomName.isEmpty
    }
    
    func saveHabit(context: ModelContext, settings: SettingsManager) {
        let existingHabits = (try? context.fetch(FetchDescriptor<HabitProfile>())) ?? []
        for existingHabit in existingHabits {
            context.delete(existingHabit)
        }

        let normalizedLastSlipDate = min(lastSlipDate, Date())

        let habit = HabitProfile(
            name: resolvedHabitName,
            mode: selectedMode,
            startDate: normalizedLastSlipDate,
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
        habit.lastSlipDate = normalizedLastSlipDate
        
        context.insert(habit)
        
        // Mark onboarding complete
        settings.hasCompletedOnboarding = true
    }
}
