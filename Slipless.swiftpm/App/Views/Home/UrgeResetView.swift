import SwiftUI

struct UrgeResetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var habit: HabitProfile
    
    enum UrgeState {
        case intro
        case breathing
        case replacement
        case outcome
    }
    
    @State private var currentState: UrgeState = .intro
    @State private var timeRemaining: TimeInterval = 60
    @State private var timer: Timer?
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                switch currentState {
                case .intro:
                    introView
                case .breathing:
                    breathingView
                case .replacement:
                    replacementView
                case .outcome:
                    outcomeView
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: currentState)
        }
    }
    
    // MARK: - Views
    
    var introView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("This feeling will pass.")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            Text("Take 60 seconds to reset.")
                .font(.title3)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                startBreathing()
            }) {
                Text("Start")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
    
    var breathingView: some View {
        VStack {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 200 * scale, height: 200 * scale)
                
                Circle()
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                    .frame(width: 200 * scale, height: 200 * scale)
                
                Text("\(Int(timeRemaining))")
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(isInhale ? "Breathe In" : "Breathe Out")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 60)
        }
    }
    
    var replacementView: some View {
        VStack(spacing: 20) {
            Text("Do one thing now.")
                .font(.title).bold()
                .foregroundColor(.white)
                .padding(.top, 40)
            
            ScrollView {
                VStack(spacing: 12) {
                    let actions = ["Drink a glass of water", "Walk for 2 minutes", "Put phone away", "10 Deep breaths", "Call a friend", "Do 10 pushups"]
                    
                    ForEach(actions, id: \.self) { action in
                        Button(action: {
                            currentState = .outcome
                        }) {
                            HStack {
                                Text(action)
                                    .font(.body)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    var outcomeView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("How do you feel?")
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            Button(action: {
                recordUrge(outcome: "passed")
                dismiss()
            }) {
                Text("Urge Passed")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
            }
            
            Button(action: {
                // Still struggling - maybe restart or dismiss
                dismiss()
            }) {
                Text("Still Struggling")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(16)
            }
            
            Button(action: {
                // Redirect to slip log?
                // For now just dismiss, user can tap Log Slip on home
                dismiss()
            }) {
                Text("I Slipped")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Logic
    
    var isInhale: Bool {
        let cycle = 8.0 // 4 in, 4 out
        let progress = timeRemaining.truncatingRemainder(dividingBy: cycle)
        return progress > 4.0
    }
    
    func startBreathing() {
        currentState = .breathing
        // Start animation loop
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            scale = 1.5
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                withAnimation(.linear(duration: 1)) {
                    timeRemaining -= 1
                }
            } else {
                timer?.invalidate()
                currentState = .replacement
            }
        }
    }
    
    func recordUrge(outcome: String) {
        let urge = UrgeEvent(date: Date(), duration: 60, outcome: outcome)
        habit.urges.append(urge)
        // SwiftData autosave
    }
}
