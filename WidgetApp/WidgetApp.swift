//
//  WidgetAppApp.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
import IQKeyboardManagerSwift

@main
struct WidgetAppApp: App {
    let syncObserver = SyncObserver()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        IQKeyboardManager.shared.enable = true
        UIPageControl.appearance().currentPageIndicatorTintColor = .lightGray
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.darkGray.withAlphaComponent(1)
    }
}

class SyncObserver {
    let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
    let icloudDefaults = NSUbiquitousKeyValueStore.default
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(yourUpdateMethod),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default)
    }
    
    @objc func yourUpdateMethod(notification: Notification) {
        for key in icloudDefaults.dictionaryRepresentation.keys {
            let value = icloudDefaults.object(forKey: key)
            sharedDefaults?.set(value, forKey: key)
        }

        print("Transfering data")
    }
}
