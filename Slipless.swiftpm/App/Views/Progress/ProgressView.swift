import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query private var habits: [HabitProfile]
    var habit: HabitProfile? { habits.first }
    
    struct Milestone: Identifiable {
        let id = UUID()
        let days: Int
        let title: String
        var isUnlocked: Bool
    }
    
    var milestones: [Milestone] {
        guard let habit = habit else { return [] }
        let currentDays = Calendar.current.dateComponents([.day], from: habit.lastSlipDate ?? habit.startDate, to: Date()).day ?? 0
        
        let targets = [1, 3, 7, 14, 30, 60, 90, 180, 365]
        return targets.map { target in
            Milestone(days: target, title: "\(target) Days", isUnlocked: currentDays >= target)
        }
    }
    
    var body: some View {
        NavigationStack {
            if let habit = habit {
                List {
                    Section(header: Text("Stats")) {
                        HStack {
                            Text("Start Date")
                            Spacer()
                            Text(habit.startDate.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.gray)
                        }
                        
                        if let money = habit.moneySavedPerDay {
                            HStack {
                                Text("Money Saved")
                                Spacer()
                                let fromDate = habit.lastSlipDate ?? habit.startDate
                                let days = Calendar.current.dateComponents([.day], from: fromDate, to: Date()).day ?? 0
                                Text((Double(days) * money).formatted(.currency(code: habit.currencyCode)))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        HStack {
                            Text("Urges Overcome")
                            Spacer()
                            Text("\(habit.urges.filter { $0.outcome == "passed" }.count)")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Section(header: Text("Milestones")) {
                        ForEach(milestones) { milestone in
                            HStack {
                                Image(systemName: milestone.isUnlocked ? "medal.fill" : "medal")
                                    .foregroundColor(milestone.isUnlocked ? .yellow : .gray)
                                
                                Text(milestone.title)
                                    .fontWeight(milestone.isUnlocked ? .bold : .regular)
                                    .foregroundColor(milestone.isUnlocked ? .primary : .gray)
                                
                                Spacer()
                                
                                if milestone.isUnlocked {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Progress")
            } else {
                ContentUnavailableView("No Data", systemImage: "chart.bar")
            }
        }
    }
}
