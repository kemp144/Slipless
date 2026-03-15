import SwiftUI
import SwiftData
import UIKit

private struct ExportSharePayload: Identifiable {
    let id = UUID()
    let activityItems: [Any]
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HabitProfile.createdDate, order: .reverse) private var habits: [HabitProfile]
    @Environment(SettingsManager.self) private var settings

    @State private var showingResetAlert = false
    @State private var exportSharePayload: ExportSharePayload?
    @State private var showingExportOptions = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                List {
                    Section(header: Text("Reminders").appTextShadow(opacity: 0.28, radius: 1.5, y: 1)) {
                        Toggle("Daily Check-in Reminder", isOn: Bindable(settings).dailyReminderEnabled)

                        if settings.dailyReminderEnabled {
                            DatePicker(
                                "Reminder Time",
                                selection: dailyReminderTime,
                                displayedComponents: .hourAndMinute
                            )
                        }
                    }

                    Section(header: Text("Privacy").appTextShadow(opacity: 0.28, radius: 1.5, y: 1)) {
                        Toggle("Stealth Mode", isOn: Bindable(settings).isStealthModeEnabled)
                        Text("Hides habit names on the home screen.")
                            .font(.caption)
                            .foregroundColor(.appSecondaryText)
                            .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)

                        Toggle("Require Face ID", isOn: Bindable(settings).faceIDLockEnabled)
                        Text("Locks the app when you come back to it.")
                            .font(.caption)
                            .foregroundColor(.appSecondaryText)
                            .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                    }

                    Section(header: Text("Data").appTextShadow(opacity: 0.28, radius: 1.5, y: 1)) {
                        Button(action: {
                            showingExportOptions = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Progress Summary")
                                    .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
                            }
                        }
                        .disabled(habits.first == nil)
                    }

                    Section(header: Text("Legal").appTextShadow(opacity: 0.28, radius: 1.5, y: 1)) {
                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            Text("Privacy Policy")
                                .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
                        }
                    }

                    Section {
                        Button("Reset All Data", role: .destructive) {
                            showingResetAlert = true
                        }
                    }

                    Section(header: Text("About").appTextShadow(opacity: 0.28, radius: 1.5, y: 1)) {
                        HStack {
                            Text("Version")
                                .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundColor(.appSecondaryText)
                                .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.appRowFill)
            }
            .navigationTitle("Settings")
            .alert("Reset Everything?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("This will delete your habit, progress, and history. This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsSheet(
                    shareTextAction: {
                        showingExportOptions = false
                        DispatchQueue.main.async {
                            shareTextSummary()
                        }
                    },
                    shareImageAction: {
                        showingExportOptions = false
                        DispatchQueue.main.async {
                            shareImageCard()
                        }
                    }
                )
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
                .presentationBackground(.thinMaterial)
            }
            .sheet(item: $exportSharePayload) { payload in
                ShareSheet(activityItems: payload.activityItems)
            }
        }
        .task(id: reminderSyncToken) {
            await ReminderManager.syncReminders(for: habits.first, settings: settings)
        }
    }

    private var dailyReminderTime: Binding<Date> {
        Binding(
            get: {
                let calendar = Calendar.current
                return calendar.date(from: DateComponents(hour: settings.dailyReminderHour, minute: settings.dailyReminderMinute)) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                settings.dailyReminderHour = components.hour ?? 20
                settings.dailyReminderMinute = components.minute ?? 0
            }
        )
    }

    private var reminderSyncToken: String {
        let habit = habits.first
        return [
            settings.dailyReminderEnabled.description,
            String(settings.dailyReminderHour),
            String(settings.dailyReminderMinute),
            habit?.id.uuidString ?? "none",
            String(habit?.slips.count ?? 0),
            String(habit?.urges.count ?? 0)
        ].joined(separator: "|")
    }

    func resetData() {
        for habit in habits {
            modelContext.delete(habit)
        }

        settings.hasCompletedOnboarding = false
        settings.isStealthModeEnabled = false
        settings.dailyReminderEnabled = false
        settings.dailyReminderHour = 20
        settings.dailyReminderMinute = 0
        settings.faceIDLockEnabled = false

        try? modelContext.save()
    }

    private func shareTextSummary() {
        guard let habit = habits.first else { return }
        let text = ProgressAnalytics.generateExportSummaryText(profile: habit, isStealthMode: settings.isStealthModeEnabled)
        exportSharePayload = ExportSharePayload(activityItems: [text])
    }

    @MainActor
    private func shareImageCard() {
        guard let habit = habits.first else { return }

        let streakDays = habit.currentStreakDays
        let title = settings.isStealthModeEnabled ? "Progress Summary" : habit.name
        let moneySavedText: String?
        if let moneySaved = habit.moneySavedPerDay, moneySaved > 0 {
            moneySavedText = (Double(streakDays) * moneySaved).formatted(.currency(code: habit.currencyCode))
        } else {
            moneySavedText = nil
        }

        let timeSavedText: String?
        if let timeSavedPerDay = habit.timeSavedPerDay, timeSavedPerDay > 0 {
            timeSavedText = formatMinutes(streakDays * timeSavedPerDay)
        } else {
            timeSavedText = nil
        }

        let renderer = ImageRenderer(
            content: ProgressShareCard(
                title: title,
                streakText: "\(streakDays) days",
                urgesWon: habit.urges.filter { $0.outcome == "passed" }.count,
                slipsLogged: habit.slips.count,
                moneySavedText: moneySavedText,
                timeSavedText: timeSavedText
            )
        )
        renderer.scale = UIScreen.main.scale

        if let image = renderer.uiImage {
            exportSharePayload = ExportSharePayload(activityItems: [image])
        } else {
            shareTextSummary()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct ExportOptionsSheet: View {
    let shareTextAction: () -> Void
    let shareImageAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: 42, height: 5)
                .padding(.top, 8)

            Text("Export Progress")
                .font(.headline)
                .foregroundColor(.appPrimaryText)

            Button(action: shareTextAction) {
                Label("Share Text Summary", systemImage: "doc.text")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)

            Button(action: shareImageAction) {
                Label("Share Image Card", systemImage: "photo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
        .padding(.horizontal, 20)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("""
            # Privacy Policy

            Slipless stores your habit data locally on your device using SwiftData.

            We do not require an account.
            We do not upload your habit history to a server.
            We do not include third-party analytics or ad SDKs.
            We do not sell personal information.

            The app stores simple preferences, such as onboarding completion and Stealth Mode, in UserDefaults on your device.

            If you export a progress summary, the export is initiated by you through the standard iOS share sheet.
            Slipless does not automatically send your data anywhere.

            If you have questions about privacy, contact the app publisher through the support information provided with the App Store listing.
            """)
            .foregroundColor(.appPrimaryText)
            .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}
