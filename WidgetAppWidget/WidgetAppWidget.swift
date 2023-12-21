//
//  WidgetAppWidget.swift
//  WidgetAppWidget
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(text: "Just some quote", configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let text = sharedDefaults?.object(forKey: "widgetContent") as? String
        return SimpleEntry(text: text ?? "Couldn't load data", configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let text = sharedDefaults?.object(forKey: "widgetContent") as? String
            let entry = SimpleEntry(text: text ?? "Couldn't load data", configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date = Date()
    let text: String
    let configuration: ConfigurationAppIntent
}

struct WidgetAppWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.text)
    }
}

struct WidgetAppWidget: Widget {
    let kind: String = "WidgetAppWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WidgetAppWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    WidgetAppWidget()
} timeline: {
    SimpleEntry(text: "Test 1", configuration: .smiley)
    SimpleEntry(text: "Test 2", configuration: .starEyes)
}
