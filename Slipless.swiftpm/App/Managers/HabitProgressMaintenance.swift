import Foundation
import SwiftData

extension HabitProfile {
    func recalculateLastSlipDate() {
        let slipDates = slips.map(\.date)
        let slippedCheckInDates = checkIns.filter { $0.status == .slipped }.map(\.date)
        lastSlipDate = (slipDates + slippedCheckInDates).max()
    }

    func syncAutoSlip(for checkIn: DailyCheckIn, previousDate: Date? = nil, modelContext: ModelContext) {
        let calendar = Calendar.current

        if let previousDate {
            removeAutoSlip(on: previousDate, modelContext: modelContext, calendar: calendar)
        }

        removeAutoSlip(on: checkIn.date, modelContext: modelContext, calendar: calendar)

        if checkIn.status == .slipped {
            let autoSlip = SlipEvent(
                date: checkIn.date,
                trigger: "Daily Check-in",
                intensity: 1,
                note: "Logged from daily check-in"
            )
            slips.append(autoSlip)
        }

        recalculateLastSlipDate()
    }

    func removeAutoSlip(on date: Date, modelContext: ModelContext, calendar: Calendar = .current) {
        guard let slip = slips.first(where: {
            calendar.isDate($0.date, inSameDayAs: date)
            && $0.trigger == "Daily Check-in"
            && $0.note == "Logged from daily check-in"
        }) else {
            return
        }

        if let index = slips.firstIndex(where: { $0.id == slip.id }) {
            slips.remove(at: index)
        }
        modelContext.delete(slip)
    }
}