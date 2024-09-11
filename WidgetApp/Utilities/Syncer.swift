//
//  Syncer.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 13.08.2024.
//

import Foundation
import SwiftData

@MainActor
class Syncer {
	private let localDefaults = UserDefaults(suiteName: bundleID)
	
	let modelContainer: ModelContainer
	
	internal init(modelContainer: ModelContainer) {
		self.modelContainer = modelContainer
	}
	
	func transferSwiftDataToLocalSettings() {
		if let objects = try? modelContainer.mainContext.fetch(FetchDescriptor<WidgetSettingsSwiftData>()) {
			objects.forEach { widgetSettings in
				
				guard let widgetId = widgetSettings.widgetId else { return }
				guard let widgetType = widgetSettings.widgetFamily else { return }
				
				localDefaults?.set(widgetSettings.text, forKey: "\(widgetId)-widgetContent")
				localDefaults?.set(widgetSettings.fontSize, forKey: "\(widgetId)-\(widgetType)-widgetFontSize")
				localDefaults?.set(widgetSettings.color, forKey: "\(widgetId)-\(widgetType)-widgetColor")
				localDefaults?.set(widgetSettings.isBold, forKey: "\(widgetId)-\(widgetType)-widgetBold")
			}
		}
	}
}
