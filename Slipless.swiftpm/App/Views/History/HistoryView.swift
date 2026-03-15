import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SlipEvent.date, order: .reverse) var slips: [SlipEvent]
    @Query(sort: \UrgeEvent.date, order: .reverse) var urges: [UrgeEvent]
    @Query(sort: \DailyCheckIn.date, order: .reverse) var checkIns: [DailyCheckIn]
    
    @State private var selectedTab = 0
    @State private var editingSlip: SlipEvent?
    @State private var editingUrge: UrgeEvent?
    @State private var editingCheckIn: DailyCheckIn?
    @State private var deleteTarget: DeleteTarget?
    
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

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if selectedTab == 0 {
                                ForEach(slips) { slip in
                                    historyRow {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(alignment: .top) {
                                                Text(slip.date.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.headline)
                                                    .appTextShadow()

                                                Spacer()

                                                historyActions(
                                                    onEdit: { editingSlip = slip },
                                                    onDelete: { deleteTarget = .slip(slip) }
                                                )
                                            }
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
                                }
                            } else if selectedTab == 1 {
                                ForEach(urges) { urge in
                                    historyRow {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                HStack(alignment: .top) {
                                                    Text(urge.date.formatted(date: .abbreviated, time: .shortened))
                                                        .font(.headline)
                                                        .appTextShadow()

                                                    Spacer()

                                                    historyActions(
                                                        onEdit: { editingUrge = urge },
                                                        onDelete: { deleteTarget = .urge(urge) }
                                                    )
                                                }
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
                                }
                            } else {
                                ForEach(checkIns) { checkIn in
                                    historyRow {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(alignment: .top) {
                                                Text(checkIn.date.formatted(date: .abbreviated, time: .omitted))
                                                    .font(.headline)
                                                    .appTextShadow()

                                                Spacer()

                                                historyActions(
                                                    onEdit: { editingCheckIn = checkIn },
                                                    onDelete: { deleteTarget = .checkIn(checkIn) }
                                                )
                                            }
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
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("History")
            .sheet(item: $editingSlip) { slip in
                EditSlipView(slip: slip)
            }
            .sheet(item: $editingUrge) { urge in
                EditUrgeView(urge: urge)
            }
            .sheet(item: $editingCheckIn) { checkIn in
                EditCheckInView(checkIn: checkIn)
            }
            .alert(deleteAlertTitle, isPresented: deleteAlertIsPresented) {
                Button("Cancel", role: .cancel) { deleteTarget = nil }
                Button("Delete", role: .destructive) {
                    performDelete()
                }
            } message: {
                Text(deleteAlertMessage)
            }
        }
    }

    @ViewBuilder
    func historyRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    func historyActions(onEdit: @escaping () -> Void, onDelete: @escaping () -> Void) -> some View {
        Menu {
            Button("Edit", action: onEdit)
            Button("Delete", role: .destructive, action: onDelete)
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(.appSecondaryText)
                .font(.title3)
        }
    }

    private var deleteAlertTitle: String {
        switch deleteTarget {
        case .slip:
            return "Delete slip?"
        case .urge:
            return "Delete urge?"
        case .checkIn:
            return "Delete check-in?"
        case nil:
            return "Delete item?"
        }
    }

    private var deleteAlertMessage: String {
        switch deleteTarget {
        case .slip:
            return "This can change your current streak and progress history."
        case .urge:
            return "This urge entry will be removed from your history."
        case .checkIn:
            return "This check-in will be removed from your history."
        case nil:
            return ""
        }
    }

    private var deleteAlertIsPresented: Binding<Bool> {
        Binding(
            get: { deleteTarget != nil },
            set: { isPresented in
                if !isPresented {
                    deleteTarget = nil
                }
            }
        )
    }

    private func performDelete() {
        guard let deleteTarget else { return }

        switch deleteTarget {
        case .slip(let slip):
            if let habit = slip.habit,
               let index = habit.slips.firstIndex(where: { $0.id == slip.id }) {
                habit.slips.remove(at: index)
                habit.recalculateLastSlipDate()
            }
            modelContext.delete(slip)

        case .urge(let urge):
            if let habit = urge.habit,
               let index = habit.urges.firstIndex(where: { $0.id == urge.id }) {
                habit.urges.remove(at: index)
            }
            modelContext.delete(urge)

        case .checkIn(let checkIn):
            if let habit = checkIn.habit {
                habit.removeAutoSlip(on: checkIn.date, modelContext: modelContext)
                if let index = habit.checkIns.firstIndex(where: { $0.id == checkIn.id }) {
                    habit.checkIns.remove(at: index)
                }
                habit.recalculateLastSlipDate()
            }
            modelContext.delete(checkIn)
        }

        try? modelContext.save()
        self.deleteTarget = nil
    }
}

private enum DeleteTarget {
    case slip(SlipEvent)
    case urge(UrgeEvent)
    case checkIn(DailyCheckIn)
}
