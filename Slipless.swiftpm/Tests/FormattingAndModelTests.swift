import XCTest
@testable import SliplessCore

final class FormattingAndModelTests: XCTestCase {

    func testOnboardingViewModel_RejectsWhitespaceOnlyCustomName() {
        let viewModel = OnboardingViewModel()
        viewModel.selectedPreset = HabitPreset(id: "custom", name: "Custom", icon: "star", category: "Other")
        viewModel.customName = "   "

        XCTAssertFalse(viewModel.isValidHabitName)
    }

    func testOnboardingViewModel_UsesTrimmedCustomName() {
        let viewModel = OnboardingViewModel()
        viewModel.selectedPreset = HabitPreset(id: "custom", name: "Custom", icon: "star", category: "Other")
        viewModel.customName = "  Reading  "

        XCTAssertEqual(viewModel.resolvedHabitName, "Reading")
    }

    func testStreakString_UsesMinutesForShortDurations() {
        let date = Date().addingTimeInterval(-(12 * 60))

        let result = TimeFormatter.streakString(from: date)

        XCTAssertEqual(result.0, "12")
        XCTAssertEqual(result.1, "Minutes")
    }

    func testStreakString_UsesHoursBeforeDayBoundary() {
        let date = Date().addingTimeInterval(-(23 * 3600 + 15 * 60))

        let result = TimeFormatter.streakString(from: date)

        XCTAssertEqual(result.0, "23")
        XCTAssertEqual(result.1, "Hours")
    }

    func testDetailedStreak_UsesDaysAndHours() {
        let interval: TimeInterval = 191_400
        let date = Date().addingTimeInterval(-interval)

        let result = TimeFormatter.detailedStreak(from: date)

        XCTAssertTrue(result.hasPrefix("2d 5h"), "Expected a day/hour formatted string, got: \(result)")
    }

    func testDailyCheckIn_NormalizesToStartOfDay() {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 14
        components.hour = 18
        components.minute = 42
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!

        let checkIn = DailyCheckIn(date: date, feeling: .okay, urgeLevel: .little, status: .onTrack)

        let normalizedComponents = calendar.dateComponents([.hour, .minute], from: checkIn.date)
        XCTAssertEqual(normalizedComponents.hour, 0)
        XCTAssertEqual(normalizedComponents.minute, 0)
    }

    func testGenerateExportSummary_UsesLastSlipDateWhenNewerThanSlipEvents() {
        let startDate = Date().addingTimeInterval(-20 * 86400)
        let profile = HabitProfile(name: "Focus", mode: .quit, startDate: startDate)
        profile.slips.append(SlipEvent(date: Date().addingTimeInterval(-10 * 86400), intensity: 3))
        profile.lastSlipDate = Date().addingTimeInterval(-2 * 86400)

        let summary = ProgressAnalytics.generateExportSummaryText(profile: profile, isStealthMode: false)

        XCTAssertTrue(summary.contains("Current Streak: 2 days"), "Expected export summary to use the newest lastSlipDate. Summary was:\n\(summary)")
    }

    func testDetermineMostCommonTrigger_IgnoresEmptyTriggers() {
        let slips = [
            SlipEvent(trigger: ""),
            SlipEvent(trigger: nil),
            SlipEvent(trigger: "Stress"),
            SlipEvent(trigger: "Stress"),
            SlipEvent(trigger: "Boredom")
        ]

        let result = ProgressAnalytics.determineMostCommonTrigger(slips: slips)

        XCTAssertEqual(result, "\"Stress\" is a common trigger lately.")
    }

    func testDetermineDifficultTimeOfDay_ReturnsExpectedBucket() {
        let calendar = Calendar(identifier: .gregorian)
        let base = calendar.startOfDay(for: Date())
        let events = [
            calendar.date(byAdding: .hour, value: 21, to: base)!,
            calendar.date(byAdding: .hour, value: 22, to: base)!,
            calendar.date(byAdding: .hour, value: 21, to: base)!
        ]

        let result = ProgressAnalytics.determineDifficultTimeOfDay(events: events)

        XCTAssertEqual(result, "Evenings seem to be the hardest for you.")
    }
}
