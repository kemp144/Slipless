import SwiftUI

struct SlipLogView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var habit: HabitProfile
    
    @State private var date = Date()
    @State private var intensity = 3.0
    @State private var selectedTrigger: String?
    @State private var note = ""
    @State private var showingResetWarning = false
    
    let triggers = ["Stress", "Boredom", "Social", "Tiredness", "Habit Loop", "Other"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                Form {
                    Section(header: Text("When did it happen?")) {
                        DatePicker("Date & Time", selection: $date)

                        if willResetCurrentStreak {
                            Text("This slip is newer than your current last slip and will reset your streak.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    Section(header: Text("Trigger")) {
                        Picker("What triggered it?", selection: $selectedTrigger) {
                            Text("Select...").tag(String?.none)
                            ForEach(triggers, id: \.self) { trigger in
                                Text(trigger).tag(String?.some(trigger))
                            }
                        }
                    }

                    Section(header: Text("Intensity (1-5)")) {
                        Slider(value: $intensity, in: 1...5, step: 1) {
                            Text("Intensity")
                        }
                        HStack {
                            Text("Mild")
                            Spacer()
                            Text("Strong")
                        }
                        .font(.caption)
                        .foregroundColor(.appSecondaryText)
                    }

                    Section(header: Text("Note")) {
                        TextEditor(text: $note)
                            .frame(height: 100)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listRowBackground(Color.appRowFill)
            .navigationTitle("Log Slip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSaveTapped()
                    }
                    .bold()
                }
            }
            .alert("Reset current streak?", isPresented: $showingResetWarning) {
                Button("Cancel", role: .cancel) { }
                Button("Log Slip", role: .destructive) {
                    saveSlip()
                    dismiss()
                }
            } message: {
                Text("This slip is later than your current streak start and will update your streak to begin from this new slip date.")
            }
        }
    }

    var willResetCurrentStreak: Bool {
        guard let lastSlipDate = habit.lastSlipDate else { return true }
        return date > lastSlipDate
    }

    func handleSaveTapped() {
        if willResetCurrentStreak {
            showingResetWarning = true
            return
        }

        saveSlip()
        dismiss()
    }
    
    func saveSlip() {
        let slip = SlipEvent(date: date, trigger: selectedTrigger, intensity: Int(intensity), note: note)
        habit.slips.append(slip)
        
        // Update habit last slip date if this slip is more recent
        if let last = habit.lastSlipDate {
            if date > last {
                habit.lastSlipDate = date
            }
        } else {
            habit.lastSlipDate = date
        }
    }
}
