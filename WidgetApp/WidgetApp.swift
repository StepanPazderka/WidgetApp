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
    let syncObserver = iCloudService()
	
	@State var selectedWidgetNo = 0
	@ObservedObject var widgetSettingsRepository = WidgetSettingsRepository()
	
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
    }
}
