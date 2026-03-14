import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [HabitProfile]
    @Environment(SettingsManager.self) private var settings
    
    @State private var showingResetAlert = false
    @State private var showingShareSheet = false
    @State private var exportSummaryText = ""
    
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
                                exportSummaryText = ProgressAnalytics.generateExportSummaryText(profile: habit, isStealthMode: settings.isStealthModeEnabled)
                                showingShareSheet = true
                            }
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
                        NavigationLink {
                            AppReviewNotesView()
                        } label: {
                            Text("App Review Notes")
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
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [exportSummaryText])
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

struct AppReviewNotesView: View {
    var body: some View {
        ScrollView {
            Text("""
            # App Review Notes
            
            **Slipless** is a self-improvement utility for tracking habits.
            
            - No medical claims are made.
            - No user accounts or login required.
            - All data is stored locally on the device using SwiftData.
            - No analytics SDKs, ad SDKs, subscriptions, or in-app purchases are included.
            - "Stealth Mode" allows users to hide sensitive custom habit names for privacy.
            - "Urge Reset" is a simple breathing timer.
            - A Daily Check-in can also record a slip and update the user's streak data.
            
            Users can enter custom habit names, allowing them to track any personal habit they wish to reduce or quit, while the app remains neutral and completely private.
            """)
            .foregroundColor(.appPrimaryText)
            .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
            .padding()
        }
        .navigationTitle("Review Notes")
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
