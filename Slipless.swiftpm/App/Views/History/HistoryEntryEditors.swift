import SwiftUI
import SwiftData

struct EditSlipView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let slip: SlipEvent

    @State private var date: Date
    @State private var intensity: Double
    @State private var selectedTrigger: String?
    @State private var note: String

    private let triggers = ["Stress", "Boredom", "Social", "Tiredness", "Habit Loop", "Other"]

    init(slip: SlipEvent) {
        self.slip = slip
        _date = State(initialValue: slip.date)
        _intensity = State(initialValue: Double(slip.intensity))
        _selectedTrigger = State(initialValue: slip.trigger)
        _note = State(initialValue: slip.note ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                Form {
                    Section(header: Text("When did it happen?")) {
                        DatePicker("Date & Time", selection: $date)
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
                        Slider(value: $intensity, in: 1...5, step: 1)
                    }

                    Section(header: Text("Note")) {
                        TextEditor(text: $note)
                            .frame(height: 100)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listRowBackground(Color.appRowFill)
            .navigationTitle("Edit Slip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .bold()
                }
            }
        }
    }

    private func save() {
        slip.date = date
        slip.intensity = Int(intensity)
        slip.trigger = selectedTrigger
        slip.note = note.isEmpty ? nil : note
        slip.habit?.recalculateLastSlipDate()
        try? modelContext.save()
        dismiss()
    }
}

struct EditUrgeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let urge: UrgeEvent

    @State private var date: Date
    @State private var durationMinutes: Double
    @State private var outcome: String

    init(urge: UrgeEvent) {
        self.urge = urge
        _date = State(initialValue: urge.date)
        _durationMinutes = State(initialValue: max(1, urge.duration / 60))
        _outcome = State(initialValue: urge.outcome)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                Form {
                    Section(header: Text("When was it?")) {
                        DatePicker("Date & Time", selection: $date)
                    }

                    Section(header: Text("Duration")) {
                        Stepper("\(Int(durationMinutes)) minutes", value: $durationMinutes, in: 1...60)
                    }

                    Section(header: Text("Outcome")) {
                        Picker("Outcome", selection: $outcome) {
                            Text("Passed").tag("passed")
                            Text("Struggled").tag("struggled")
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listRowBackground(Color.appRowFill)
            .navigationTitle("Edit Urge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        urge.date = date
                        urge.duration = durationMinutes * 60
                        urge.outcome = outcome
                        try? modelContext.save()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

struct EditCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let checkIn: DailyCheckIn

    @State private var date: Date
    @State private var feeling: CheckInFeeling
    @State private var urgeLevel: CheckInUrgeLevel
    @State private var status: CheckInStatus

    init(checkIn: DailyCheckIn) {
        self.checkIn = checkIn
        _date = State(initialValue: checkIn.date)
        _feeling = State(initialValue: checkIn.feeling)
        _urgeLevel = State(initialValue: checkIn.urgeLevel)
        _status = State(initialValue: checkIn.status)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                Form {
                    Section(header: Text("Day")) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }

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
            .navigationTitle("Edit Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .bold()
                }
            }
        }
    }

    private func save() {
        let previousDate = checkIn.date
        let normalizedDate = Calendar.current.startOfDay(for: date)
        checkIn.date = normalizedDate
        checkIn.feeling = feeling
        checkIn.urgeLevel = urgeLevel
        checkIn.status = status
        checkIn.habit?.syncAutoSlip(for: checkIn, previousDate: previousDate, modelContext: modelContext)
        try? modelContext.save()
        dismiss()
    }
}