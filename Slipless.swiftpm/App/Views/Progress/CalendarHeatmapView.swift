import SwiftUI

struct CalendarHeatmapView: View {
    let habit: HabitProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            let days = generateCalendarDays()

            VStack(alignment: .leading, spacing: 4) {
                Text("Last 30 Days")
                    .font(.headline)
                    .appTextShadow()

                Text("Older days are on the left. Today's square has a white outline.")
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
                    .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
            }

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(days, id: \.date) { dayData in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorForStatus(dayData.status))
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(dayData.isToday ? Color.white.opacity(0.9) : Color.clear, lineWidth: 2)
                        }
                        .aspectRatio(1.0, contentMode: .fit)
                        .opacity(dayData.isInRange ? 1 : 0.22)
                        .accessibilityLabel(accessibilityLabel(for: dayData))
                }
            }

            HStack {
                Text(shortDateLabel(for: days.first(where: { $0.isInRange })?.date))
                Spacer()
                Text("Today")
            }
            .font(.caption2)
            .foregroundColor(.appSecondaryText)
            .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)

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
        let isToday: Bool
        let isInRange: Bool
    }

    func generateCalendarDays() -> [DayData] {
        var days: [DayData] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for i in (0..<35).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let isInRange = i < 30
            var status: DayStatus = .neutral

            if isInRange, date >= calendar.startOfDay(for: habit.startDate) {
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
            
            days.append(
                DayData(
                    date: date,
                    status: status,
                    isToday: calendar.isDateInToday(date),
                    isInRange: isInRange
                )
            )
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

    func shortDateLabel(for date: Date?) -> String {
        guard let date else { return "" }
        return date.formatted(.dateTime.day().month(.abbreviated))
    }

    func accessibilityLabel(for dayData: DayData) -> String {
        let dateText = dayData.date.formatted(date: .abbreviated, time: .omitted)
        let statusText: String = switch dayData.status {
        case .clean: "Clean"
        case .slip: "Slip"
        case .urge: "Urge"
        case .neutral: dayData.isInRange ? "No activity" : "Outside the last 30 days"
        }

        if dayData.isToday {
            return "Today, \(dateText), \(statusText)"
        }

        return "\(dateText), \(statusText)"
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
                .foregroundColor(.appSecondaryText)
                .appTextShadow(opacity: 0.28, radius: 1.5, y: 1)
        }
    }
}
