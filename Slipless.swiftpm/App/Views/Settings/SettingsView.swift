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
                    Section(header: Text("Privacy")) {
                        Toggle("Stealth Mode", isOn: Bindable(settings).isStealthModeEnabled)
                        Text("Hides habit names in widgets and home screen.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Section(header: Text("Data")) {
                        Button(action: {
                            if let habit = habits.first {
                                exportSummaryText = ProgressAnalytics.generateExportSummaryText(profile: habit, isStealthMode: settings.isStealthModeEnabled)
                                showingShareSheet = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Progress Summary")
                            }
                        }
                        .disabled(habits.first == nil)
                    }

                    Section(header: Text("Legal")) {
                        Link("Privacy Policy", destination: URL(string: settings.privacyPolicyURL)!)
                        NavigationLink("App Review Notes", destination: AppReviewNotesView())
                    }

                    Section {
                        Button("Reset All Data", role: .destructive) {
                            showingResetAlert = true
                        }
                    }

                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.white.opacity(0.08))
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
            - "Stealth Mode" allows users to hide sensitive custom habit names for privacy.
            - "Urge Reset" is a simple breathing timer.
            
            Users can enter custom habit names, allowing them to track any personal habit they wish to reduce or quit, while the app remains neutral and completely private.
            """)
            .padding()
        }
        .navigationTitle("Review Notes")
    }
}
