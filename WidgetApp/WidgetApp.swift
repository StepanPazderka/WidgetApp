//
//  WidgetAppApp.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
import SwiftData
import IQKeyboardManagerSwift

@main
struct WidgetAppApp: App {
    @ObservedObject private var widgetSettingsRepository = WidgetSettingsRepository()

    init() {
        IQKeyboardManager.shared.enable = true
        UIPageControl.appearance().currentPageIndicatorTintColor = .lightGray
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.darkGray.withAlphaComponent(1)
    }

    var body: some Scene {
        WindowGroup {
            WidgetCarousel(selectedWidgetNo: 0)
        }
        .environmentObject(widgetSettingsRepository)
        .modelContainer(try! WidgetDataStore.makeModelContainer())
    }
}
