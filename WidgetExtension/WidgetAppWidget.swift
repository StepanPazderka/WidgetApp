//
//  WidgetAppWidget.swift
//  WidgetAppWidget
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import WidgetKit
import SwiftUI

struct WidgetAppWidget: Widget {
    let kind: String = "WidgetAppWidget"
//	@ObservedObject var widgetSettingsRepository = WidgetSettingsRepository.standard
    
#if os(iOS)
    var body: some WidgetConfiguration {
		AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            let color = entry.color
			
			WidgetAppWidgetEntryView(entry: entry)
                .containerBackground(entry.color, for: .widget)
                .foregroundStyle(color.complementaryColor(for: color))
                .fontWeight( entry.shouldBeBold ? .bold : .regular)
				.modelContainer(for: [WidgetSettingsSwiftData.self])
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
