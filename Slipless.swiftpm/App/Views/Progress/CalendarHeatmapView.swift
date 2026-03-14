import SwiftUI

struct CalendarHeatmapView: View {
    let habit: HabitProfile
    
    // Simple mock implementation of a 30-day heatmap for V1
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last 30 Days")
                .font(.headline)
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            let days = generateLast30Days()
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(days, id: \.date) { dayData in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForStatus(dayData.status))
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            
            HStack(spacing: 12) {
                LegendItem(color: .green.opacity(0.8), label: "Clean")
                LegendItem(color: .blue.opacity(0.8), label: "Urge")
                LegendItem(color: .orange.opacity(0.8), label: "Slip")
                LegendItem(color: .gray.opacity(0.2), label: "None")
            }
            .font(.caption2)
            .padding(.top, 4)
        }
        .padding()
        .appCardStyle()
    }
    
    enum DayStatus {
        case clean, slip, urge, neutral
    }
    
    struct DayData {
        let date: Date
        let status: DayStatus
    }
    
    func generateLast30Days() -> [DayData] {
        var days: [DayData] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for i in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            // Determine status
            var status: DayStatus = .neutral
            
            if date >= calendar.startOfDay(for: habit.startDate) {
                status = .clean // Default to clean if after start date
                
                let slipsOnDay = habit.slips.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let urgesOnDay = habit.urges.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let checkInsOnDay = habit.checkIns.filter { calendar.isDate($0.date, inSameDayAs: date) }
                
                if !slipsOnDay.isEmpty {
                    status = .slip
                } else if checkInsOnDay.contains(where: { $0.status == .slipped }) {
                    status = .slip
                } else if !urgesOnDay.isEmpty {
                    status = .urge
                }
            }
            
            days.append(DayData(date: date, status: status))
        }
        return days
    }
    
    func colorForStatus(_ status: DayStatus) -> Color {
        switch status {
        case .clean: return .green.opacity(0.8)
        case .slip: return .orange.opacity(0.8)
        case .urge: return .blue.opacity(0.8)
        case .neutral: return .gray.opacity(0.2)
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}
