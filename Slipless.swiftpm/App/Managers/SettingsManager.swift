import Foundation
import SwiftUI

@Observable
class SettingsManager {
    var isStealthModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isStealthModeEnabled, forKey: "isStealthModeEnabled")
        }
    }
    
    var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }

    var dailyReminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(dailyReminderEnabled, forKey: "dailyReminderEnabled")
        }
    }

    var dailyReminderHour: Int {
        didSet {
            UserDefaults.standard.set(dailyReminderHour, forKey: "dailyReminderHour")
        }
    }

    var dailyReminderMinute: Int {
        didSet {
            UserDefaults.standard.set(dailyReminderMinute, forKey: "dailyReminderMinute")
        }
    }

    var faceIDLockEnabled: Bool {
        didSet {
            UserDefaults.standard.set(faceIDLockEnabled, forKey: "faceIDLockEnabled")
        }
    }

    var appStoreDemoModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(appStoreDemoModeEnabled, forKey: "appStoreDemoModeEnabled")
        }
    }
    
    init() {
        self.isStealthModeEnabled = UserDefaults.standard.bool(forKey: "isStealthModeEnabled")
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.dailyReminderEnabled = UserDefaults.standard.bool(forKey: "dailyReminderEnabled")

        let storedHour = UserDefaults.standard.object(forKey: "dailyReminderHour") as? Int
        self.dailyReminderHour = storedHour ?? 20

        let storedMinute = UserDefaults.standard.object(forKey: "dailyReminderMinute") as? Int
        self.dailyReminderMinute = storedMinute ?? 0

        self.faceIDLockEnabled = UserDefaults.standard.bool(forKey: "faceIDLockEnabled")
        self.appStoreDemoModeEnabled = UserDefaults.standard.bool(forKey: "appStoreDemoModeEnabled")
    }
}
