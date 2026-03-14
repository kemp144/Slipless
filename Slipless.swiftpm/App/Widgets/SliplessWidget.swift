import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    // In a real app, use a shared ModelContainer with App Group
    // For this code sample, we assume the default container is accessible or mocked
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), streak: "12 Days", habitName: "Gaming", isStealth: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), streak: "12 Days", habitName: "Gaming", isStealth: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Fetch data from SwiftData
        // Note: Requires App Group setup in production
        
        // Mock data for V1 demonstration
        let entry = SimpleEntry(date: Date(), streak: "14 Days", habitName: "On Track", isStealth: true)
        
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let streak: String
    let habitName: String
    let isStealth: Bool
}

struct SliplessWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Slipless")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(entry.streak)
                    .font(.largeTitle)
                    .bold()
                    .minimumScaleFactor(0.5)
                
                Text(entry.isStealth ? "Focus" : entry.habitName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                if family == .systemMedium {
                    HStack {
                        Link(destination: URL(string: "slipless://urge")!) {
                            Text(entry.isStealth ? "Support" : "Urge")
                                .font(.caption)
                                .padding(6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Link(destination: URL(string: "slipless://slip")!) {
                            Text("Log")
                                .font(.caption)
                                .padding(6)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Link(destination: URL(string: "slipless://checkin")!) {
                            Text("Check-in")
                                .font(.caption)
                                .padding(6)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

struct SliplessWidget: Widget {
    let kind: String = "SliplessWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SliplessWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SliplessWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Slipless Streak")
        .description("Track your progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
