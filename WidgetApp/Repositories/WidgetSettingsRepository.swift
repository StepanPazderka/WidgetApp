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
	private let icloudDefaults = NSUbiquitousKeyValueStore.default
	private let localDefaults = UserDefaults(suiteName: bundleID)
	
	@Published var widgetSettings: [WidgetSettings] = []
	
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		widgetSettings = fetchWidgetSettings()
		setupObservation()
	}
	
	func fetchWidgetSettings() -> [WidgetSettings] {
		(0...100).flatMap { id -> [WidgetSettings] in
			return WidgetTypes.allCases.compactMap { widgetSize -> WidgetSettings? in
				let widgetFontSize = self.localDefaults?.object(forKey: "\(id)-\(widgetSize)-widgetFontSize") as? CGFloat
				let widgetIsBold = self.localDefaults?.object(forKey: "\(id)-\(widgetSize)-widgetBold") as? Bool
				if let widgetContent = self.localDefaults?.object(forKey: "\(id)-widgetContent") as? String
				{
					return WidgetSettings(id: id, text: widgetContent, shouldBeBold: widgetIsBold ?? false, color: .primary, fontSize: widgetFontSize ?? 20.0)
				}
				return nil
			}
		}
	}
	
	func setupObservation() {
		NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification, object: localDefaults)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				if let widgetSettings = self?.fetchWidgetSettings() {
					self?.widgetSettings = widgetSettings
				}
			}
			.store(in: &cancellables)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(iCloudDefaultsUpdateClosure),
			name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
			object: NSUbiquitousKeyValueStore.default)
	}
	
	@objc func iCloudDefaultsUpdateClosure(notification: Notification) {
		for key in icloudDefaults.dictionaryRepresentation.keys {
			let value = icloudDefaults.object(forKey: key)
			localDefaults?.set(value, forKey: key)
		}
		
		guard let localDefaults else { return }
		
		for key in localDefaults.dictionaryRepresentation().keys {
			let icloudValue = icloudDefaults.object(forKey: key)
			
			if icloudValue == nil {
				localDefaults.removeObject(forKey: key)
			}
		}
		
		DispatchQueue.main.sync {
			widgetSettings = fetchWidgetSettings()
		}
	}

	@discardableResult func createNewWidgetSettings() -> Int? {
		let widgetContent = "This is a preview text that will be in the widget"
		let widgetShouldBeBold = false
		let widgetColor: Color = .primary
		let widgetFontSize = 20.0
		
		var newWidgetID: Int?
		
		if let lastWidgetID = widgetSettings.last?.id {
			newWidgetID = lastWidgetID + 1
		} else {
			newWidgetID = 0
		}
		
		guard let newWidgetID else { return nil }
		
		withAnimation {
			for widgetType in WidgetTypes.allCases {
				localDefaults?.set(widgetContent, forKey: "\(newWidgetID)-widgetContent")
				localDefaults?.set(widgetFontSize, forKey: "\(newWidgetID)-\(widgetType)-widgetFontSize")
				localDefaults?.set(widgetColor.rawValue, forKey: "\(newWidgetID)-\(widgetType)-widgetColor")
				localDefaults?.set(widgetShouldBeBold, forKey: "\(newWidgetID)-\(widgetType)-widgetBold")
			}
		}
		
		return newWidgetID
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
	
	func refreshWidgetSettings() {
		self.widgetSettings = fetchWidgetSettings()
	}
}
