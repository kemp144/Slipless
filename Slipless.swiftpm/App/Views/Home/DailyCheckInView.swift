import SwiftUI
import SwiftData

struct DailyCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let habit: HabitProfile
    
    @State private var feeling: CheckInFeeling = .okay
    @State private var urgeLevel: CheckInUrgeLevel = .none
    @State private var status: CheckInStatus = .onTrack
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                Form {
                    Section(header: Text("How was today?")) {
                        Picker("Feeling", selection: $feeling) {
                            Text("Easy").tag(CheckInFeeling.easy)
                            Text("Okay").tag(CheckInFeeling.okay)
                            Text("Hard").tag(CheckInFeeling.hard)
                        }
                        .pickerStyle(.segmented)
                    }

                    Section(header: Text("Did you feel an urge?")) {
                        Picker("Urge Level", selection: $urgeLevel) {
                            Text("No").tag(CheckInUrgeLevel.none)
                            Text("A little").tag(CheckInUrgeLevel.little)
                            Text("Yes").tag(CheckInUrgeLevel.yes)
                        }
                        .pickerStyle(.segmented)
                    }

                    Section(header: Text("Are you still on track?")) {
                        Picker("Status", selection: $status) {
                            Text("Yes").tag(CheckInStatus.onTrack)
                            Text("Had a slip").tag(CheckInStatus.slipped)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listRowBackground(Color.appRowFill)
            .navigationTitle("Daily Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCheckIn()
                    }
                }
            }
        }
    }
    
    private func saveCheckIn() {
        let checkIn = DailyCheckIn(feeling: feeling, urgeLevel: urgeLevel, status: status)
        habit.checkIns.append(checkIn)

        if status == .slipped {
            let slipDate = Date()
            if let lastSlipDate = habit.lastSlipDate {
                if slipDate > lastSlipDate {
                    habit.lastSlipDate = slipDate
                }
            } else {
                habit.lastSlipDate = slipDate
            }

            let calendar = Calendar.current
            let alreadyLoggedSlipToday = habit.slips.contains {
                calendar.isDate($0.date, inSameDayAs: slipDate)
            }

            if !alreadyLoggedSlipToday {
                habit.slips.append(
                    SlipEvent(
                        date: slipDate,
                        trigger: "Daily Check-in",
                        intensity: 1,
                        note: "Logged from daily check-in"
                    )
                )
            }
        }

        try? modelContext.save()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss()
    }
}
