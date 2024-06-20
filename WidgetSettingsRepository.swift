//
//  WidgetSettingsRepository.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import Observation
import SwiftUI
import Combine

class WidgetSettingsRepository: ObservableObject {
	
	private var cancellables = Set<AnyCancellable>()
	
	private let icloudDefaults = NSUbiquitousKeyValueStore.default
	private var localDefaults = UserDefaults(suiteName: bundleID)
	
	@Published var widgetSettings: [WidgetSettings] = []
	
	init() {
		widgetSettings = loadWidgetSettings()
		setupObservation()
	}
	
	func loadWidgetSettings() -> [WidgetSettings] {
		var array: [WidgetSettings] = []
		for id in 0...10 {
			for widgetSize in WidgetTypes.allCases {
				if let widgetContent = self.localDefaults?.object(forKey: "\(id)-widgetContent") as? String
				{
					let widgetSettings = WidgetSettings(id: id, text: widgetContent, shouldBeBold: false, color: .primary, fontSize: 20.0)
					array.append(widgetSettings)
				}
			}
		}
		
//		print("Length of Widge Settings \(array.count)")
//		print("Number of unique IDs \(array.uniqued(on: \.id).count)")
//		for id in array.uniqued(on: \.id) {
//			print("Widget Settings: \(id)")
//		}
		
		return array
	}
	
	func setupObservation() {
		NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification, object: localDefaults)
			.sink { [weak self] something in
				if let widgetSettings = self?.loadWidgetSettings() {
					self?.widgetSettings = widgetSettings
				}
			}
			.store(in: &cancellables)
	}

	func createNewWidgetSettings() {
		let widgetContent = "Preview content"
		let widgetShouldBeBold = false
		let widgetColor: Color = .primary
		let widgetFontSize = 20.0
		
		var newWidgetID: Int?
		
		if let lastWidgetID = widgetSettings.last?.id {
			newWidgetID = lastWidgetID + 1
		} else {
			newWidgetID = 0
		}
		
		guard let newWidgetID else { return }
		for widgetType in WidgetTypes.allCases {
			localDefaults?.set(widgetContent, forKey: "\(newWidgetID)-widgetContent")
			localDefaults?.set(widgetFontSize, forKey: "\(newWidgetID)-\(widgetType)-widgetFontSize")
			localDefaults?.set(widgetColor.rawValue, forKey: "\(newWidgetID)-\(widgetType)-widgetColor")
			localDefaults?.set(widgetShouldBeBold, forKey: "\(newWidgetID)-\(widgetType)-widgetBold")
		}
	}
	
	func deleteWidgetSettings(id: Int) {
		for widgetType in WidgetTypes.allCases {
			localDefaults?.removeObject(forKey: "\(id)-widgetContent")
			localDefaults?.removeObject(forKey: "\(id)-\(widgetType)-widgetFontSize")
			localDefaults?.removeObject(forKey: "\(id)-\(widgetType)-widgetColor")
			localDefaults?.removeObject(forKey: "\(id)-\(widgetType)-widgetBold")
		}
	}
}
