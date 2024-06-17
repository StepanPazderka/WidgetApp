//
//  SyncObserver.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 12.04.2024.
//

import Foundation

class iCloudService {
	let localDefaults = UserDefaults(suiteName: bundleID)
	let icloudDefaults = NSUbiquitousKeyValueStore.default
	
	init() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(updateLocalDefaults),
			name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
			object: NSUbiquitousKeyValueStore.default)
	}
	
	@objc func updateLocalDefaults(notification: Notification) {
		for key in icloudDefaults.dictionaryRepresentation.keys {
			let value = icloudDefaults.object(forKey: key)
			localDefaults?.set(value, forKey: key)
		}
	}
}
