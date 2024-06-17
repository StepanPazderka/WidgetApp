//
//  UserDefaults+appGroup.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 17.05.2024.
//

import Foundation

public extension UserDefaults {
	static let appGroup = UserDefaults(suiteName: "group.com.pazderka.widgetApp")!
}
