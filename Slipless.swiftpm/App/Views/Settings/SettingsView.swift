import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [HabitProfile]
    @Environment(SettingsManager.self) private var settings
    
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Privacy")) {
                    Toggle("Stealth Mode", isOn: Bindable(settings).isStealthModeEnabled)
                    Text("Hides habit names in widgets and home screen.")
                        .font(.caption)
                        .foregroundColor(.gray)
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
            .navigationTitle("Settings")
            .alert("Reset Everything?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("This will delete your habit, progress, and history. This action cannot be undone.")
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

struct AppReviewNotesView: View {
    var body: some View {
        ScrollView {
            Text("""
            # App Review Notes
            
            **Slipless** is a self-improvement utility for tracking habits.
            
            - No medical claims are made.
            - No user accounts or login required.
            - All data is stored locally on the device using SwiftData.
            - "Stealth Mode" allows users to hide sensitive habit names for privacy.
            - "Urge Reset" is a simple breathing timer.
            
            ## Mature Content
            The app includes optional presets for "Alcohol" or "Porn" for users struggling with those habits. These can be disabled in the source code via `HabitPreset.swift` if required for specific rating targets, but the app is designed to be neutral and non-explicit regardless of the chosen habit.
            """)
            .padding()
        }
        .navigationTitle("Review Notes")
    }
}
