//
//  WidgetSettingsRepository.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import Observation
import SwiftUI
import Combine
import WidgetKit

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
		for id in 0...100 {
			for widgetSize in WidgetTypes.allCases {
				let widgetFontSize = self.localDefaults?.object(forKey: "\(id)-\(widgetSize)-widgetFontSize") as? CGFloat
				let widgetIsBold = self.localDefaults?.object(forKey: "\(id)-\(widgetSize)-widgetBold") as? Bool
				if let widgetContent = self.localDefaults?.object(forKey: "\(id)-widgetContent") as? String
				{
					let widgetSettings = WidgetSettings(id: id, text: widgetContent, shouldBeBold: widgetIsBold ?? false, color: .primary, fontSize: widgetFontSize ?? 20.0)
					array.append(widgetSettings)
				}
			}
		}
		
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
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(updateLocalDefaults),
			name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
			object: NSUbiquitousKeyValueStore.default)
	}
	
	@objc func updateLocalDefaults(notification: Notification) {
		DispatchQueue.main.sync {
			widgetSettings = loadWidgetSettings()
		}
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
			
			icloudDefaults.removeObject(forKey: "\(id)-widgetContent")
			icloudDefaults.removeObject(forKey: "\(id)-\(widgetType)-widgetFontSize")
			icloudDefaults.removeObject(forKey: "\(id)-\(widgetType)-widgetColor")
			icloudDefaults.removeObject(forKey: "\(id)-\(widgetType)-widgetBold")
		}
	}
}
