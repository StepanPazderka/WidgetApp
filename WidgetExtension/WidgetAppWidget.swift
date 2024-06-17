//
//  WidgetAppWidget.swift
//  WidgetAppWidget
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    let localDefaults = UserDefaults(suiteName: bundleID)
    let icloudDefaults = NSUbiquitousKeyValueStore.default
    
	// MARK: - Placeholder for when previewing widget when on homescreen
    func placeholder(in context: Context) -> WidgetSettings {
        let fontSize = localDefaults?.object(forKey: "widgetFontSize") as? CGFloat
        
        return WidgetSettings(text: "Your text will be displayed here", shouldBeBold: false, color: .primary, fontSize: fontSize ?? 20.0)
    }
    
	// MARK: - Snapshot when updating timeline
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WidgetSettings {
        let text = localDefaults?.object(forKey: "0-widgetContent") as? String
        var widgetType: WidgetTypes?
        
        if context.family == .systemSmall {
            widgetType = .systemSmall
            print("Small: \(context.displaySize)")
            let smallWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            localDefaults?.set(smallWidgetSize, forKey: "smallWidgetSize")
        } else if context.family == .systemMedium {
            print("Medium: \(context.displaySize)")
            widgetType = .systemMedium
            let mediumWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            localDefaults?.set(mediumWidgetSize, forKey: "mediumWidgetSize")
        } else if context.family == .systemLarge {
            print("Large: \(context.displaySize)")
            widgetType = .systemLarge
            let largeWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            localDefaults?.set(largeWidgetSize, forKey: "largeWidgetSize")
        } else if context.family == .systemExtraLarge {
            print("Extra large: \(context.displaySize)")
            widgetType = .systemExtraLarge
            let extraLargeWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            localDefaults?.set(extraLargeWidgetSize, forKey: "extraLargeWidgetSize")
        }
		#if os(iOS)
        if context.family == .accessoryRectangular {
            widgetType = .accessoryRectangular
            print("Rectangular: \(context.displaySize)")
        } else if context.family == .accessoryCircular {
            widgetType = .accessoryCircular
            print("Circular: \(context.displaySize)")
        }
		#endif
        
        let fontSize = localDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetFontSize") as? CGFloat
        let shouldBeBold = localDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetBold") as? Bool
        let colorData = localDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetColor") as? String
        var color: Color?
        
        if let colorData {
            color = Color(rawValue: colorData)
        }
        return WidgetSettings(text: text ?? "Preview text", shouldBeBold: shouldBeBold ?? false, color: color ?? .primary, fontSize: fontSize ?? 20.0)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WidgetSettings> {
        var entries: [WidgetSettings] = []
        
        var widgetType: WidgetTypes?
        if context.family == .systemSmall {
            widgetType = .systemSmall
            print("Small: \(context.displaySize)")
            let smallWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            localDefaults?.set(smallWidgetSize, forKey: "smallWidgetSize")
        } else if context.family == .systemMedium {
            print("Medium: \(context.displaySize)")
            widgetType = .systemMedium
            let mediumWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            localDefaults?.set(mediumWidgetSize, forKey: "mediumWidgetSize")
        } else if context.family == .systemLarge {
            print("Large: \(context.displaySize)")
            widgetType = .systemLarge
            let largeWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            localDefaults?.set(largeWidgetSize, forKey: "largeWidgetSize")
        } else if context.family == .systemExtraLarge {
            print("Extra large: \(context.displaySize)")
            widgetType = .systemExtraLarge
            let extraLargeWidgetSize: [String: CGFloat] = [
                "width": context.displaySize.width,
                "height": context.displaySize.height
            ]
            localDefaults?.set(extraLargeWidgetSize, forKey: "extraLargeWidgetSize")
        }
		#if os(iOS)
        if context.family == .accessoryRectangular {
            widgetType = .accessoryRectangular
            print("Rectangular: \(context.displaySize)")
        } else if context.family == .accessoryCircular {
            widgetType = .accessoryCircular
            print("Circular: \(context.displaySize)")
        }
		#endif
        
        let widgetContent = localDefaults?.object(forKey: "0-widgetContent") as? String
        let widgetFontSize = localDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetFontSize") as? CGFloat
        let widgetBoldSetting = localDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetBold") as? Bool
        let widgetColor = localDefaults?.object(forKey: "0-\(widgetType?.rawValue ?? "systemSmall")-widgetColor") as? String
        var color: Color?
        
		#if os(iOS)
        if context.family == .accessoryRectangular {
            print("Showing rectangular")
        }
		#endif
        
        if let widgetColor {
            color = Color(rawValue: widgetColor)
        }
        let entry = WidgetSettings(text: widgetContent ?? "Couldn't load data", shouldBeBold: widgetBoldSetting ?? false, color: color ?? .primary, fontSize: widgetFontSize ?? 20.0)
        entries.append(entry)
        return Timeline(entries: entries, policy: .never)
    }
}



struct WidgetAppWidgetEntryView: View {
	@State var widgetText: String = "Your text will be here"
	@State var widgetFontSize: CGFloat = 20.0
	@State var color: Color = .primary
	@State var shouldBeBold: Bool = false
	@Environment(\.widgetFamily) var family

    var entry: Provider.Entry
    
    init(entry: WidgetSettings) {
        self.entry = entry
        self.color = entry.color
        self.widgetText = entry.text
		self.widgetFontSize = entry.fontSize
    }
    
    var body: some View {
        switch family {
        case .systemMedium:
            Link(destination: URL(string: "echoframe://systemMedium")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        case .systemSmall:
            Link(destination: URL(string: "echoframe://systemSmall")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        case .systemLarge:
            Link(destination: URL(string: "echoframe://systemLarge")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        case .systemExtraLarge:
            Link(destination: URL(string: "echoframe://systemExtraLarge")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        case .accessoryCircular:
            Link(destination: URL(string: "echoframe://accessoryCircular")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
                    .foregroundStyle(.white)
            }
        case .accessoryRectangular:
            Link(destination: URL(string: "echoframe://accessoryRectangular")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
                    .foregroundStyle(.white)
            }
        case .accessoryInline:
            Link(destination: URL(string: "echoframe://accessoryInline")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
                    .foregroundStyle(.white)
            }
        @unknown default:
            Link(destination: URL(string: "echoframe://")!) {
				WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        }
        
    }
}

struct WidgetAppWidget: Widget {
    let kind: String = "WidgetAppWidget"
    
#if os(iOS)
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, provider: Provider()) { entry in
            let color = entry.color
            
            WidgetAppWidgetEntryView(entry: entry)
                .containerBackground(entry.color, for: .widget)
                .font(.system(size: entry.fontSize))
                .foregroundStyle(color.complementaryColor(for: color))
                .fontWeight( entry.shouldBeBold ? .bold : .regular)
        }
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
#elseif os(macOS)
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, provider: Provider()) { entry in
            let color = entry.color
            
            WidgetAppWidgetEntryView(entry: entry)
                .containerBackground(entry.color, for: .widget)
                .font(.system(size: entry.fontSize))
                .foregroundStyle(color.complementaryColor(for: color))
                .fontWeight( entry.shouldBeBold ? .bold : .regular)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
#endif
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

#if os(iOS)
#Preview(as: .accessoryRectangular) {
    WidgetAppWidget()
} timeline: {
	WidgetSettings(text: "Just a very simple text", shouldBeBold: true, color: .accentColor, fontSize: 20.0)
}
#endif

#Preview(as: .systemMedium) {
    WidgetAppWidget()
} timeline: {
    WidgetSettings(text: "Just a very simple text", shouldBeBold: false, color: .red, fontSize: 20.0)
}

#Preview(as: .systemSmall) {
    WidgetAppWidget()
} timeline: {
    WidgetSettings(text: "Just a very simple text", shouldBeBold: true, color: .accentColor, fontSize: 20.0)
}
