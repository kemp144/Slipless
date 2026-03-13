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
    
    let privacyPolicyURL = "https://example.com/privacy-policy-placeholder" // TODO: Replace with real URL
    
    init() {
        self.isStealthModeEnabled = UserDefaults.standard.bool(forKey: "isStealthModeEnabled")
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}
