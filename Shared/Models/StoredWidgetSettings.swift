//
//  WidgetSettingsStored.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 23.04.2026.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class StoredWidgetSettings {
	var widgetId: Int = 0
	var widgetTypeRawValue: String = WidgetTypes.systemSmall.rawValue
	var text: String = ""
	var shouldBeBold: Bool = false
	var colorRawValue: String = Color.primary.rawValue
	var fontSize: Double = 20.0
	
	init(
		widgetId: Int,
		widgetTypeRawValue: String,
		text: String,
		shouldBeBold: Bool,
		colorRawValue: String,
		fontSize: Double
	) {
		self.widgetId = widgetId
		self.widgetTypeRawValue = widgetTypeRawValue
		self.text = text
		self.shouldBeBold = shouldBeBold
		self.colorRawValue = colorRawValue
		self.fontSize = fontSize
	}
	
	static func makeDefault(withWidgetId: Int) -> StoredWidgetSettings {
		let randomColor = Color(
			hue: Double.random(in: 0...1),
			saturation: Double.random(in: 0.4...1),
			brightness: Double.random(in: 0.4...1)
		)

		return StoredWidgetSettings(
			widgetId: withWidgetId,
			widgetTypeRawValue: WidgetTypes.systemSmall.rawValue,
			text: "Preview content",
			shouldBeBold: false,
			colorRawValue: randomColor.rawValue,
			fontSize: 20.0
		)
	}
}
