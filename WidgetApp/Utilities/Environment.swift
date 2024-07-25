//
//  Environmet.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 16.05.2024.
//

import SwiftUI

struct WidgetSettingsRepositoryKey: EnvironmentKey {
	static var defaultValue = WidgetSettingsRepository()
	
}

extension EnvironmentValues {
	var widgetSettingsRepository: WidgetSettingsRepository {
		get { self[WidgetSettingsRepositoryKey.self] }
		set { self[WidgetSettingsRepositoryKey.self] = newValue }
	}
}
