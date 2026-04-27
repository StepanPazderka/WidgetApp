//
//  WidgetSettings.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 12.04.2024.
//

import WidgetKit
import SwiftUI
import AppIntents

struct WidgetSettings: TimelineEntry, AppEntity, Identifiable {
	static var typeDisplayRepresentation: TypeDisplayRepresentation = "WidgetContent"
	static var defaultQuery = WidgetContentQuery()
	
	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: "\(truncateText(text, toLength: 20))")
	}
	
	let id: Int
	var date: Date = Date()
	let text: String
	let shouldBeBold: Bool
	let color: Color
	let fontSize: CGFloat
	
	init(text: String, shouldBeBold: Bool, color: Color, fontSize: CGFloat) {
		self.id = 0
		self.text = text
		self.shouldBeBold = shouldBeBold
		self.color = color
		self.fontSize = fontSize
	}
	
	init(id: Int, text: String, shouldBeBold: Bool, color: Color, fontSize: CGFloat) {
		self.id = id
		self.text = text
		self.shouldBeBold = shouldBeBold
		self.color = color
		self.fontSize = fontSize
	}
	
	static func empty() -> WidgetSettings {
		.init(text: "Enter widget text here", shouldBeBold: false, color: .accentColor, fontSize: 20.0)
	}
}

extension WidgetSettings: Hashable { }

extension WidgetSettings: Codable { }
