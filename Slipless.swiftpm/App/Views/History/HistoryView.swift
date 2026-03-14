import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \SlipEvent.date, order: .reverse) var slips: [SlipEvent]
    @Query(sort: \UrgeEvent.date, order: .reverse) var urges: [UrgeEvent]
    @Query(sort: \DailyCheckIn.date, order: .reverse) var checkIns: [DailyCheckIn]
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                VStack {
                    Picker("Type", selection: $selectedTab) {
                        Text("Slips").tag(0)
                        Text("Urges").tag(1)
                        Text("Check-ins").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    List {
                        if selectedTab == 0 {
                            ForEach(slips) { slip in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(slip.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.headline)
                                        .appTextShadow()
                                    if let trigger = slip.trigger, !trigger.isEmpty {
                                        Text("Trigger: \(trigger)")
                                            .font(.caption)
                                            .foregroundColor(.appSecondaryText)
                                            .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                                    }
                                    if let note = slip.note, !note.isEmpty {
                                        Text(note)
                                            .font(.caption)
                                            .foregroundColor(.appSecondaryText)
                                            .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                                    }
                                }
                            }
                        } else if selectedTab == 1 {
                            ForEach(urges) { urge in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(urge.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.headline)
                                            .appTextShadow()
                                        Text(urge.outcome.capitalized)
                                            .font(.caption)
                                            .foregroundColor(urge.outcome == "passed" ? .green : .orange)
                                            .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
                                    }
                                    Spacer()
                                    if urge.outcome == "passed" {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        } else {
                            ForEach(checkIns) { checkIn in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(checkIn.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.headline)
                                        .appTextShadow()
                                    HStack {
                                        Text("Felt: \(checkIn.feeling.rawValue.capitalized)")
                                        Spacer()
                                        Text("Urges: \(checkIn.urgeLevel.rawValue.capitalized)")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.appSecondaryText)
                                    .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)

                                    Text(checkIn.status == .onTrack ? "On Track" : "Slipped")
                                        .font(.caption)
                                        .foregroundColor(checkIn.status == .onTrack ? .green : .red)
                                        .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(Color.appRowFill)
                }
            }
            .navigationTitle("History")
        }
    }
}
