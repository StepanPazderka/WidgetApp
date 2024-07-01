//
//  WidgetAppWidget.swift
//  WidgetAppWidget
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import WidgetKit
import SwiftUI

struct WidgetAppWidgetEntryView: View {
	@State var id: Int
	@State var widgetText: String = "Your text will be here"
	@State var widgetFontSize: CGFloat = 20.0
	@State var color: Color = .primary
	@State var shouldBeBold: Bool = false
	@Environment(\.widgetFamily) var family

    var entry: Provider.Entry
    
    init(entry: WidgetSettings) {
		self.id = entry.id
        self.entry = entry
        self.color = entry.color
        self.widgetText = entry.text
		self._widgetFontSize = State(initialValue: entry.fontSize)
    }
    
    var body: some View {
        switch family {
        case .systemMedium:
            Link(destination: URL(string: "echoframe://\(id)/systemMedium")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        case .systemSmall:
            Link(destination: URL(string: "echoframe://\(id)/systemSmall")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        case .systemLarge:
            Link(destination: URL(string: "echoframe://\(id)/systemLarge")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        case .systemExtraLarge:
            Link(destination: URL(string: "echoframe://\(id)/systemExtraLarge")!) {
				WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
            }
        case .accessoryCircular:
            Link(destination: URL(string: "echoframe://\(id)/accessoryCircular")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
                    .foregroundStyle(.white)
            }
        case .accessoryRectangular:
            Link(destination: URL(string: "echoframe://\(id)/accessoryRectangular")!) {
                WidgetView(text: .constant(entry.text), fontSize: $widgetFontSize, shouldBeBold: $shouldBeBold, textPadding: .constant(0))
                    .foregroundStyle(.white)
            }
        case .accessoryInline:
            Link(destination: URL(string: "echoframe://\(id)/accessoryInline")!) {
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
		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            let color = entry.color
			
			WidgetAppWidgetEntryView(entry: entry)
                .containerBackground(entry.color, for: .widget)
                .foregroundStyle(color.complementaryColor(for: color))
                .fontWeight( entry.shouldBeBold ? .bold : .regular)
        }
		.configurationDisplayName("Widget Settings")
		.description("Sets a Widget Settings to display")
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
