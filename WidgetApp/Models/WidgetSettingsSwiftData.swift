//
//  WidgetSettingsSwiftData.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 30.07.2024.
//

import SwiftUI
import SwiftData

@Model
class WidgetSettingsSwiftData {
	var widgetId: Int?
	var color: String = Color.primary.rawValue
	var text: String = ""
	var isBold: Bool = false
	var fontSize: CGFloat = 20.0
	var widgetFamily: WidgetTypes?
	
	internal init(widgetId: Int, color: Color, text: String, isBold: Bool, fontSize: CGFloat, widgetFamily: WidgetTypes) {
		self.widgetId = widgetId
		self.color = color.rawValue
		self.text = text
		self.isBold = isBold
		self.fontSize = fontSize
		self.widgetFamily = widgetFamily
	}
	
	internal init() {
		self.widgetId = Int.random(in: 0...10)
		self.color = Color.primary.rawValue
		self.text = "New widget"
		self.isBold = true
		self.fontSize = 20.0
		self.widgetFamily = .systemSmall
	}
	
	var debugDescription: String {
		let widgetIdDescription = widgetId != nil ? "\(widgetId!)" : "nil"
		let widgetFamilyDescription = widgetFamily != nil ? "\(widgetFamily!)" : "nil"
		
		return """
		WidgetSettingsSwiftData(
			widgetId: \(widgetIdDescription),
			color: \(color),
			text: "\(text)",
			isBold: \(isBold),
			fontSize: \(fontSize),
			widgetFamily: \(widgetFamilyDescription)
		)
		"""
	}
}
