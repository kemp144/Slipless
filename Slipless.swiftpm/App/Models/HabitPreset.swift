import Foundation

struct HabitPreset: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String // SF Symbol
    let category: String

    static let allPresets: [HabitPreset] = [
        HabitPreset(id: "sugar", name: "Sugar", icon: "birthday.cake", category: "Health"),
        HabitPreset(id: "alcohol", name: "Alcohol", icon: "wineglass", category: "Substances"),
        HabitPreset(id: "smoking", name: "Smoking", icon: "flame", category: "Substances"),
        HabitPreset(id: "gaming", name: "Gaming", icon: "gamecontroller", category: "Behavior"),
        HabitPreset(id: "doomscrolling", name: "Doomscrolling", icon: "iphone", category: "Behavior"),
        HabitPreset(id: "nail_biting", name: "Nail Biting", icon: "hand.raised", category: "Behavior"),
        HabitPreset(id: "custom", name: "Custom", icon: "star", category: "Other")
    ]

    static var availablePresets: [HabitPreset] {
        return allPresets
    }
}
