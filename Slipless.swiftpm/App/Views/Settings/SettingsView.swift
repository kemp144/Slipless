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
                        Text("Hides habit names in widgets and home screen.")
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

                        if !settings.appStoreDemoModeEnabled {
                            Button(action: {
                                loadScreenshotDemoData()
                            }) {
                                HStack {
                                    Image(systemName: "sparkles.rectangle.stack")
                                    Text("Load App Store Demo Data")
                                        .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
                                }
                            }
                        }
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
        // Delete all habits
        for habit in habits {
            modelContext.delete(habit)
        }
        
        // Reset settings
        settings.hasCompletedOnboarding = false
        settings.isStealthModeEnabled = false
        settings.appStoreDemoModeEnabled = false
        
        // Force save/sync (though SwiftData usually handles it)
        try? modelContext.save()
    }

    func loadScreenshotDemoData() {
        for habit in habits {
            modelContext.delete(habit)
        }

        let calendar = Calendar.current
        let now = Date()
        let journeyStart = calendar.date(byAdding: .day, value: -150, to: now) ?? now
        let lastSlipDate = calendar.date(byAdding: .day, value: -43, to: now) ?? journeyStart

        func demoDate(daysAgo: Int, hour: Int, minute: Int = 0) -> Date {
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
        }

        let habit = HabitProfile(
            name: "Smoking",
            mode: .quit,
            startDate: journeyStart,
            moneySavedPerDay: 9.5,
            timeSavedPerDay: 42,
            currencyCode: CurrencySupport.currentCurrencyCode,
            primaryReasonText: "I want my lungs, mornings, and peace of mind back.",
            noteToSelf: "One craving is not a command. Pause, breathe, move on."
        )

        habit.lastSlipDate = lastSlipDate
        habit.reasons = [
            PinnedReason(text: "Breathe easier"),
            PinnedReason(text: "Save money"),
            PinnedReason(text: "Be present with family")
        ]

        habit.slips = [
            SlipEvent(
                date: demoDate(daysAgo: 128, hour: 22, minute: 10),
                trigger: "Stress",
                intensity: 3,
                note: "Late work deadline"
            ),
            SlipEvent(
                date: demoDate(daysAgo: 93, hour: 8, minute: 20),
                trigger: "Coffee",
                intensity: 2,
                note: "Morning routine"
            ),
            SlipEvent(
                date: demoDate(daysAgo: 61, hour: 19, minute: 40),
                trigger: "Social setting",
                intensity: 4,
                note: "Friday night out"
            ),
            SlipEvent(
                date: demoDate(daysAgo: 43, hour: 21, minute: 5),
                trigger: "Stress",
                intensity: 4,
                note: "Last logged slip"
            )
        ]

        habit.urges = [
            UrgeEvent(date: demoDate(daysAgo: 36, hour: 8, minute: 5), duration: 120, outcome: "passed"),
            UrgeEvent(date: demoDate(daysAgo: 31, hour: 8, minute: 12), duration: 95, outcome: "passed"),
            UrgeEvent(date: demoDate(daysAgo: 26, hour: 7, minute: 55), duration: 90, outcome: "passed"),
            UrgeEvent(date: demoDate(daysAgo: 22, hour: 8, minute: 18), duration: 110, outcome: "passed"),
            UrgeEvent(date: demoDate(daysAgo: 17, hour: 7, minute: 48), duration: 80, outcome: "struggled"),
            UrgeEvent(date: demoDate(daysAgo: 12, hour: 8, minute: 8), duration: 85, outcome: "passed"),
            UrgeEvent(date: demoDate(daysAgo: 9, hour: 7, minute: 58), duration: 100, outcome: "passed"),
            UrgeEvent(date: demoDate(daysAgo: 6, hour: 8, minute: 14), duration: 75, outcome: "passed"),
            UrgeEvent(date: demoDate(daysAgo: 3, hour: 8, minute: 6), duration: 70, outcome: "passed")
        ]

        habit.checkIns = [
            DailyCheckIn(date: demoDate(daysAgo: 7, hour: 20), feeling: .okay, urgeLevel: .little, status: .onTrack),
            DailyCheckIn(date: demoDate(daysAgo: 6, hour: 20), feeling: .easy, urgeLevel: .none, status: .onTrack),
            DailyCheckIn(date: demoDate(daysAgo: 5, hour: 20), feeling: .hard, urgeLevel: .yes, status: .onTrack),
            DailyCheckIn(date: demoDate(daysAgo: 4, hour: 20), feeling: .okay, urgeLevel: .little, status: .onTrack),
            DailyCheckIn(date: demoDate(daysAgo: 3, hour: 20), feeling: .okay, urgeLevel: .little, status: .onTrack),
            DailyCheckIn(date: demoDate(daysAgo: 2, hour: 20), feeling: .easy, urgeLevel: .none, status: .onTrack),
            DailyCheckIn(date: demoDate(daysAgo: 1, hour: 20), feeling: .easy, urgeLevel: .none, status: .onTrack)
        ]

        modelContext.insert(habit)
        settings.hasCompletedOnboarding = true
        settings.isStealthModeEnabled = false
        settings.dailyReminderEnabled = true
        settings.dailyReminderHour = 20
        settings.dailyReminderMinute = 30
        settings.faceIDLockEnabled = false
        settings.appStoreDemoModeEnabled = true

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

        let streakDays = max(0, Calendar.current.dateComponents([.day], from: habit.lastSlipDate ?? habit.startDate, to: Date()).day ?? 0)
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
