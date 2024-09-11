//
//  AppIntent.swift
//  WidgetAppWidget
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
	
	@Parameter(title: "Widget")
	var content: WidgetSettings
	
	init(content: WidgetSettings) {
		self.content = content
	}
	
	init() {
		
	}
}

struct WidgetContentQuery: EntityQuery {
	func entities(for identifiers: [WidgetSettings.ID]) async throws -> [WidgetSettings] {
		var ids = [Int]()
		var outputArray = [WidgetSettings]()
		for widgetSettings in await WidgetSettingsRepository.standard.fetchWidgetSettings() {
			if !ids.contains(widgetSettings.id) {
				ids.append(widgetSettings.id)
				outputArray.append(widgetSettings)
			}
		}
		return outputArray
	}
	
	// MARK: - Settings selectable by user in UI
	func suggestedEntities() async throws -> [WidgetSettings] {
		var ids = [Int]()
		var outputArray = [WidgetSettings]()
		for widgetSettings in await WidgetSettingsRepository.standard.fetchWidgetSettings() {
			if !ids.contains(widgetSettings.id) {
				ids.append(widgetSettings.id)
				outputArray.append(widgetSettings)
			}
		}
		return outputArray
	}
	
	func defaultResult() async -> WidgetSettings? {
		try? await suggestedEntities().first
	}
}
