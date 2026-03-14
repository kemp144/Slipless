import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    @Environment(SettingsManager.self) private var settings
    
    var body: some View {
        ZStack {
            AppWallpaperView()

            VStack {
                // Progress Bar
                SwiftUI.ProgressView(value: Double(viewModel.step + 1), total: 6.0)
                    .tint(.white)
                    .padding(.top)
                    .padding(.horizontal)
                
                Spacer()
                
                Group {
                    switch viewModel.step {
                    case 0: selectHabitView
                    case 1: selectModeView
                    case 2: selectDateView
                    case 3: savingsView
                    case 4: selectReasonsView
                    case 5: reviewView
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                
                Spacer()
                
                // Navigation Buttons
                HStack {
                    if viewModel.step > 0 {
                        Button("Back") {
                            withAnimation { viewModel.step -= 1 }
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    
                    Spacer()
                    
                    PrimaryButton(
                        title: viewModel.step == 5 ? "Start Journey" : "Next",
                        action: {
                            if viewModel.step == 5 {
                                viewModel.saveHabit(context: modelContext, settings: settings)
                            } else {
                                withAnimation { viewModel.step += 1 }
                            }
                        },
                        isDisabled: !canProceed
                    )
                    .frame(width: 150)
                }
                .padding(.bottom)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    var canProceed: Bool {
        switch viewModel.step {
        case 0: return viewModel.selectedPreset != nil && viewModel.isValidHabitName
        default: return true
        }
    }
    
    // MARK: - Step 0: Habit
    var selectHabitView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What would you like to quit?")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(HabitPreset.availablePresets) { preset in
                        OptionCard(
                            title: preset.name,
                            icon: preset.icon,
                            isSelected: viewModel.selectedPreset?.id == preset.id
                        ) {
                            viewModel.selectedPreset = preset
                            if preset.id == "custom" {
                                viewModel.customName = ""
                            }
                        }
                    }
                    
                    if viewModel.selectedPreset?.id == "custom" {
                        TextField("Enter habit name", text: $viewModel.customName)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Step 1: Mode
    var selectModeView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose your goal")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            OptionCard(
                title: "Quit Completely",
                icon: "xmark.circle",
                isSelected: viewModel.selectedMode == .quit
            ) {
                viewModel.selectedMode = .quit
            }
            
            OptionCard(
                title: "Reduce / Moderation",
                icon: "chart.bar",
                isSelected: viewModel.selectedMode == .reduce
            ) {
                viewModel.selectedMode = .reduce
            }
            
            Text(viewModel.selectedMode == .quit ? "Focus on streaks and total abstinence." : "Focus on tracking frequency and staying within limits.")
                .font(.subheadline)
                .foregroundColor(.appSecondaryText)
                .padding(.top)
        }
        .padding()
    }
    
    // MARK: - Step 2: Date
    var selectDateView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("When was your last slip?")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            DatePicker("Last Slip", selection: $viewModel.lastSlipDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .colorScheme(.dark)
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            
            Text("Your streak will be calculated from this time.")
                .font(.caption)
                .foregroundColor(.appSecondaryText)
        }
        .padding()
    }
    
    // MARK: - Step 3: Savings
    var savingsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Track your savings")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            Text("(Optional)")
                .foregroundColor(.appSecondaryText)
            
            VStack(alignment: .leading) {
                Text("Money saved per day")
                    .foregroundColor(.white)
                HStack {
                    Text(viewModel.currencyCode)
                        .foregroundColor(.appSecondaryText)
                    TextField("0.00", value: $viewModel.moneySavedPerDay, format: .currency(code: viewModel.currencyCode))
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading) {
                Text("Time saved per day (minutes)")
                    .foregroundColor(.white)
                TextField("0", value: $viewModel.timeSavedPerDay, format: .number)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
    
    // MARK: - Step 4: Reasons
    var selectReasonsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Why are you starting?")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading) {
                        Text("Your Primary Reason")
                            .foregroundColor(.white)
                        TextField("e.g. I want my time back.", text: $viewModel.primaryReasonText)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("A short note to self (Optional)")
                            .foregroundColor(.appSecondaryText)
                        TextField("e.g. Just for today.", text: $viewModel.noteToSelf)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Step 5: Review
    var reviewView: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)
            
            Text("You're ready.")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                Text("Habit: \(viewModel.resolvedHabitName)")
                Text("Mode: \(viewModel.selectedMode.rawValue.capitalized)")
                Text("Start: \(viewModel.lastSlipDate.formatted(date: .abbreviated, time: .shortened))")
            }
            .foregroundColor(.gray)
            .foregroundColor(.appSecondaryText)
            
            Text("Take it one day at a time.")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
    }
}
