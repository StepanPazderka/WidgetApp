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
    let icloudDefaults = NSUbiquitousKeyValueStore.default
    
    func placeholder(in context: Context) -> SimpleEntry {
        let fontSize = sharedDefaults?.object(forKey: "widgetFontSize") as? CGFloat

        return SimpleEntry(text: "Just some quote", shouldBeBold: false, color: .primary, fontSize: fontSize ?? 20.0)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let text = sharedDefaults?.object(forKey: "widgetContent") as? String
        let fontSize = sharedDefaults?.object(forKey: "widgetFontSize") as? CGFloat
        let shouldBeBold = sharedDefaults?.object(forKey: "widgetBold") as? Bool
        let colorData = sharedDefaults?.object(forKey: "widgetColor") as? String
        var color: Color?

        if let colorData {
            color = Color(rawValue: colorData)
        }
        return SimpleEntry(text: text ?? "Preview text", shouldBeBold: shouldBeBold ?? false, color: color ?? .primary, fontSize: fontSize ?? 20.0)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        var widgetType: WidgetTypes?
        if context.family == .systemSmall {
            widgetType = .systemSmall
            print("Small: \(context.displaySize)")
            let smallWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            sharedDefaults?.set(smallWidgetSize, forKey: "smallWidgetSize")
        } else if context.family == .systemMedium {
            print("Medium: \(context.displaySize)")
            widgetType = .systemMedium
            let mediumWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            sharedDefaults?.set(mediumWidgetSize, forKey: "mediumWidgetSize")
        } else if context.family == .systemLarge {
            print("Large: \(context.displaySize)")
            widgetType = .systemLarge
            let largeWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            sharedDefaults?.set(largeWidgetSize, forKey: "largeWidgetSize")
        } else if context.family == .systemExtraLarge {
            print("Extra large: \(context.displaySize)")
            widgetType = .systemExtraLarge
            let extraLargeWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            sharedDefaults?.set(extraLargeWidgetSize, forKey: "extraLargeWidgetSize")
        } else if context.family == .accessoryRectangular {
            widgetType = .accessoryRectangular
            print("Rectangular: \(context.displaySize)")
        } else if context.family == .accessoryCircular {
            widgetType = .accessoryCircular
            print("Circular: \(context.displaySize)")
        }
        
        let text = sharedDefaults?.object(forKey: "0-widgetContent") as? String
        let fontSize = sharedDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetFontSize") as? CGFloat
        let shouldBeBold = sharedDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetBold") as? Bool
        let colorData = sharedDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetColor") as? String
        var color: Color?
        
        if context.family == .accessoryRectangular {
            print("Showing rectangular")
        }
        
        if let colorData {
            color = Color(rawValue: colorData)
        }
        let entry = SimpleEntry(text: text ?? "Couldn't load data", shouldBeBold: shouldBeBold ?? false, color: color ?? .primary, fontSize: fontSize ?? 20.0)
        entries.append(entry)
        return Timeline(entries: entries, policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date = Date()
    let text: String
    let shouldBeBold: Bool
    let color: Color
    let fontSize: CGFloat
}

struct WidgetAppWidgetEntryView: View {
    var entry: Provider.Entry
    
    @State var widgetText: String = "Just a test"
    @State var widgetFontSize: CGFloat = 20.0
    @State var color: Color = .primary
    @State var shouldBeBold: Bool = false
    
    init(entry: SimpleEntry) {
        self.entry = entry
        self.color = entry.color
        self.widgetText = entry.text
        self._widgetFontSize = State(initialValue: entry.fontSize)
    }
    
    var body: some View {
        WidgetView(text: bindingFromString(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
    }
    
    func bindingFromString(_ string: String) -> Binding<String> {
        Binding<String>(
            get: { string },
            set: { newValue in }
        )
    }
}

struct WidgetAppWidget: Widget {
    let kind: String = "WidgetAppWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, provider: Provider()) { entry in
            let color = entry.color
            
            WidgetAppWidgetEntryView(entry: entry)
                .containerBackground(entry.color, for: .widget)
                .font(.system(size: entry.fontSize))
                .foregroundStyle(color.complementaryColor(for: color))
                .fontWeight( entry.shouldBeBold ? .bold : .regular)
        }
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall, .systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .accessoryRectangular) {
    WidgetAppWidget()
} timeline: {
    SimpleEntry(text: "Just a very simple text", shouldBeBold: true, color: .accentColor, fontSize: 20.0)
}

#Preview(as: .systemMedium) {
    WidgetAppWidget()
} timeline: {
    SimpleEntry(text: "Just a very simple text", shouldBeBold: false, color: .red, fontSize: 20.0)
}

#Preview(as: .systemSmall) {
    WidgetAppWidget()
} timeline: {
    SimpleEntry(text: "Just a very simple text", shouldBeBold: true, color: .accentColor, fontSize: 20.0)
}
