import XCTest
import SwiftData
@testable import Slipless

final class ProgressAnalyticsTests: XCTestCase {

    var startDate: Date!
    var day: TimeInterval!
    var now: Date!

    override func setUp() {
        super.setUp()
        now = Date()
        day = 86400
        startDate = now.addingTimeInterval(-day * 10) // 10 days ago
    }

    override func tearDown() {
        startDate = nil
        day = nil
        now = nil
        super.tearDown()
    }

    func testAverageTimeBetweenSlips_NoSlips() {
        // Given
        let slips: [SlipEvent] = []
        
        // When
        let average = ProgressAnalytics.calculateAverageTimeBetweenSlips(slips: slips, startDate: startDate)
        
        // Then
        XCTAssertNil(average, "Average should be nil when there are no valid slips")
    }

    func testAverageTimeBetweenSlips_OneSlipInMiddle() {
        // Given
        let slip = SlipEvent(date: startDate.addingTimeInterval(day * 5), trigger: "Stress", intensity: 3, note: nil)
        let slips = [slip]
        
        // When
        let average = ProgressAnalytics.calculateAverageTimeBetweenSlips(slips: slips, startDate: startDate)
        
        // Then
        // 5 days from start to slip + ~5 days from slip to now = ~10 days total. Divided by 2 periods = ~5 days.
        XCTAssertNotNil(average)
        XCTAssertEqual(average!, day * 5, accuracy: 2.0) // 2 seconds accuracy
    }

    func testAverageTimeBetweenSlips_SlipsBeforeStartDateIgnored() {
        // Given
        let oldSlip = SlipEvent(date: startDate.addingTimeInterval(-day * 5), trigger: "Past", intensity: 3, note: nil)
        
        // When
        let average = ProgressAnalytics.calculateAverageTimeBetweenSlips(slips: [oldSlip], startDate: startDate)
        
        // Then
        XCTAssertNil(average, "Slips before the start date should be completely ignored, treating it as no valid slips")
    }
    
    func testLongestGap_MultipleSlips() {
        // Given
        let slip1 = SlipEvent(date: startDate.addingTimeInterval(day * 2), trigger: nil, intensity: 3, note: nil)
        let slip2 = SlipEvent(date: startDate.addingTimeInterval(day * 6), trigger: nil, intensity: 3, note: nil)
        let slips = [slip1, slip2]
        
        // When
        let longestGap = ProgressAnalytics.calculateLongestGap(slips: slips, startDate: startDate)
        
        // Then
        // Periods:
        // Start -> Slip1 = 2 days
        // Slip1 -> Slip2 = 4 days
        // Slip2 -> Now = ~4 days
        XCTAssertNotNil(longestGap)
        XCTAssertEqual(longestGap!, day * 4, accuracy: 2.0)
    }
    
    func testImprovementText_Improving() {
        // Given
        // Slip 2 happened 8 days ago (2 days after start)
        let slip2 = SlipEvent(date: startDate.addingTimeInterval(day * 2), trigger: nil, intensity: 3, note: nil)
        
        // Slip 1 happened 6 days ago (4 days after start) -> Gap is 2 days
        let slip1 = SlipEvent(date: startDate.addingTimeInterval(day * 4), trigger: nil, intensity: 3, note: nil)
        
        // Gap from slip1 to now is 6 days. 6 days > 2 days -> improving!
        let slips = [slip1, slip2]
        
        // When
        let text = ProgressAnalytics.generateImprovementText(slips: slips, startDate: startDate)
        
        // Then
        XCTAssertEqual(text, "Your current streak is longer than your previous one. Great job!")
    }
    
    func testImprovementText_NotImproving() {
        // Given
        // Slip 2 happened 2 days ago
        let slip2 = SlipEvent(date: now.addingTimeInterval(-day * 2), trigger: nil, intensity: 3, note: nil)
        
        // Slip 1 happened 1 day ago -> Gap is 1 day
        let slip1 = SlipEvent(date: now.addingTimeInterval(-day * 1), trigger: nil, intensity: 3, note: nil)
        
        // Gap from slip1 to now is 1 day. 1 day is not strictly > 1 day, or maybe worse.
        let slips = [slip1, slip2]
        
        // When
        let text = ProgressAnalytics.generateImprovementText(slips: slips, startDate: startDate)
        
        // Then
        XCTAssertEqual(text, "Progress still counts. You're building resilience.")
    }
}
