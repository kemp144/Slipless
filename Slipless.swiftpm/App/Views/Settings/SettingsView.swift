import SwiftUI
import SwiftData

private struct ExportSharePayload: Identifiable {
    let id = UUID()
    let text: String
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HabitProfile.createdDate, order: .reverse) private var habits: [HabitProfile]
    @Environment(SettingsManager.self) private var settings
    
    @State private var showingResetAlert = false
    @State private var exportSharePayload: ExportSharePayload?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppWallpaperView()

                List {
                    Section(header: Text("Privacy").appTextShadow(opacity: 0.28, radius: 1.5, y: 1)) {
                        Toggle("Stealth Mode", isOn: Bindable(settings).isStealthModeEnabled)
                        Text("Hides habit names in widgets and home screen.")
                            .font(.caption)
                            .foregroundColor(.appSecondaryText)
                            .appTextShadow(opacity: 0.32, radius: 1.5, y: 1)
                    }

                    Section(header: Text("Data").appTextShadow(opacity: 0.28, radius: 1.5, y: 1)) {
                        Button(action: {
                            if let habit = habits.first {
                                exportSharePayload = ExportSharePayload(
                                    text: ProgressAnalytics.generateExportSummaryText(
                                        profile: habit,
                                        isStealthMode: settings.isStealthModeEnabled
                                    )
                                )
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Progress Summary")
                                    .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
                            }
                        }
                        .disabled(habits.first == nil)

                        Button(action: {
                            loadScreenshotDemoData()
                        }) {
                            HStack {
                                Image(systemName: "sparkles.rectangle.stack")
                                Text("Load Screenshot Demo Data")
                                    .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
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
            .sheet(item: $exportSharePayload) { payload in
                ShareSheet(activityItems: [payload.text])
            }
        }
    }
    
    func resetData() {
        // Delete all habits
        for habit in habits {
            modelContext.delete(habit)
        }
        
        // Reset settings
        settings.hasCompletedOnboarding = false
        settings.isStealthModeEnabled = false
        
        // Force save/sync (though SwiftData usually handles it)
        try? modelContext.save()
    }

    func loadScreenshotDemoData() {
        for habit in habits {
            modelContext.delete(habit)
        }

        let calendar = Calendar.current
        let now = Date()
        let journeyStart = calendar.date(byAdding: .day, value: -400, to: now) ?? now
        let lastSlipDate = calendar.date(byAdding: .day, value: -365, to: now) ?? journeyStart

        let habit = HabitProfile(
            name: "Smoking",
            mode: .quit,
            startDate: journeyStart,
            moneySavedPerDay: 8.5,
            timeSavedPerDay: 35,
            currencyCode: CurrencySupport.currentCurrencyCode,
            primaryReasonText: "I want my health, lungs, and peace of mind back.",
            noteToSelf: "One craving is not a command."
        )

        habit.lastSlipDate = lastSlipDate
        habit.reasons = [
            PinnedReason(text: "Breathe easier"),
            PinnedReason(text: "Save money"),
            PinnedReason(text: "Be present with family")
        ]

        habit.slips = [
            SlipEvent(
                date: calendar.date(byAdding: .day, value: -394, to: now) ?? now,
                trigger: "Stress",
                intensity: 3,
                note: "Work deadline"
            ),
            SlipEvent(
                date: calendar.date(byAdding: .day, value: -386, to: now) ?? now,
                trigger: "Coffee",
                intensity: 2,
                note: "Morning routine"
            ),
            SlipEvent(
                date: calendar.date(byAdding: .day, value: -365, to: now) ?? now,
                trigger: "Social setting",
                intensity: 4,
                note: "Last logged slip"
            )
        ]

        habit.urges = [
            UrgeEvent(date: calendar.date(byAdding: .day, value: -320, to: now) ?? now, duration: 90, outcome: "passed"),
            UrgeEvent(date: calendar.date(byAdding: .day, value: -250, to: now) ?? now, duration: 120, outcome: "passed"),
            UrgeEvent(date: calendar.date(byAdding: .day, value: -180, to: now) ?? now, duration: 75, outcome: "passed"),
            UrgeEvent(date: calendar.date(byAdding: .day, value: -60, to: now) ?? now, duration: 80, outcome: "passed"),
            UrgeEvent(date: calendar.date(byAdding: .day, value: -21, to: now) ?? now, duration: 65, outcome: "struggled"),
            UrgeEvent(date: calendar.date(byAdding: .day, value: -7, to: now) ?? now, duration: 95, outcome: "passed"),
            UrgeEvent(date: calendar.date(byAdding: .day, value: -2, to: now) ?? now, duration: 70, outcome: "passed")
        ]

        habit.checkIns = [
            DailyCheckIn(date: calendar.date(byAdding: .day, value: -6, to: now) ?? now, feeling: .okay, urgeLevel: .little, status: .onTrack),
            DailyCheckIn(date: calendar.date(byAdding: .day, value: -5, to: now) ?? now, feeling: .easy, urgeLevel: .none, status: .onTrack),
            DailyCheckIn(date: calendar.date(byAdding: .day, value: -4, to: now) ?? now, feeling: .okay, urgeLevel: .little, status: .onTrack),
            DailyCheckIn(date: calendar.date(byAdding: .day, value: -3, to: now) ?? now, feeling: .hard, urgeLevel: .yes, status: .onTrack),
            DailyCheckIn(date: calendar.date(byAdding: .day, value: -2, to: now) ?? now, feeling: .okay, urgeLevel: .little, status: .onTrack),
            DailyCheckIn(date: calendar.date(byAdding: .day, value: -1, to: now) ?? now, feeling: .easy, urgeLevel: .none, status: .onTrack)
        ]

        modelContext.insert(habit)
        settings.hasCompletedOnboarding = true

        try? modelContext.save()
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
