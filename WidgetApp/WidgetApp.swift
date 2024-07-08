//
//  WidgetAppApp.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
#if os(iOS)
import IQKeyboardManagerSwift
#endif

@main
struct WidgetAppApp: App {
    let syncObserver = iCloudService()
	
	@State var selectedWidgetNo = 0
	@ObservedObject var widgetSettingsRepository = WidgetSettingsRepository()
	
	init() {
		#if os(iOS)
		IQKeyboardManager.shared.enable = true
		#endif
		UIPageControl.appearance().currentPageIndicatorTintColor = .lightGray
		UIPageControl.appearance().pageIndicatorTintColor = UIColor.darkGray.withAlphaComponent(1)
	}

    var body: some Scene {
        WindowGroup {
			WidgetCarousel(selectedWidgetNo: 0)
				.navigationTitle("EchoFrame")
        }
		.environmentObject(widgetSettingsRepository)
    }
}
