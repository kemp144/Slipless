import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \SlipEvent.date, order: .reverse) var slips: [SlipEvent]
    @Query(sort: \UrgeEvent.date, order: .reverse) var urges: [UrgeEvent]
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Type", selection: $selectedTab) {
                    Text("Slips").tag(0)
                    Text("Urges").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    if selectedTab == 0 {
                        ForEach(slips) { slip in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(slip.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.headline)
                                if let trigger = slip.trigger {
                                    Text("Trigger: \(trigger)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                if let note = slip.note, !note.isEmpty {
                                    Text(note)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        ForEach(urges) { urge in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(urge.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.headline)
                                    Text(urge.outcome.capitalized)
                                        .font(.caption)
                                        .foregroundColor(urge.outcome == "passed" ? .green : .orange)
                                }
                                Spacer()
                                if urge.outcome == "passed" {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("History")
        }
    }
}
