import Foundation

struct HabitPreset: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String // SF Symbol
    let isMature: Bool
    let category: String
    
    static let allPresets: [HabitPreset] = [
        HabitPreset(id: "sugar", name: "Sugar", icon: "birthday.cake", isMature: false, category: "Health"),
        HabitPreset(id: "alcohol", name: "Alcohol", icon: "wineglass", isMature: true, category: "Substances"),
        HabitPreset(id: "smoking", name: "Smoking", icon: "flame", isMature: true, category: "Substances"),
        HabitPreset(id: "gaming", name: "Gaming", icon: "gamecontroller", isMature: false, category: "Behavior"),
        HabitPreset(id: "doomscrolling", name: "Doomscrolling", icon: "iphone", isMature: false, category: "Behavior"),
        HabitPreset(id: "gambling", name: "Gambling", icon: "die.face.5", isMature: true, category: "Behavior"),
        HabitPreset(id: "porn", name: "Porn", icon: "eye.slash", isMature: true, category: "Behavior"),
        HabitPreset(id: "custom", name: "Custom", icon: "star", isMature: false, category: "Other")
    ]
    
    // Toggle this for submission if needed
    static var availablePresets: [HabitPreset] {
        allPresets.filter { _ in
            // For a safe build, return false for mature content
            // return !$0.isMature
            return true
        }
    }
}
