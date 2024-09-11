//
//  WidgetAppWidgetEntryView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 27.08.2024.
//

import SwiftUI
import SwiftData

struct WidgetAppWidgetEntryView: View {
	@State var id: Int
	@Environment(\.widgetFamily) var family
	
	@Query(sort: \WidgetSettingsSwiftData.widgetId) private var widgetSettings: [WidgetSettingsSwiftData]
    
    init(entry: WidgetSettings) {
		self.id = entry.id
    }
    
    var body: some View {
		Link(destination: URL(string: "echoframe://\(id)/\(family)")!) {
			if let widgetSettings = widgetSettings.first(where: { $0.widgetId == id && $0.widgetFamily?.rawValue == family.description }) {
				WidgetView(text: .constant(widgetSettings.text), fontSize: .constant(widgetSettings.fontSize), shouldBeBold: .constant(widgetSettings.isBold), textPadding: .constant(0))
			}
		}
    }
}
