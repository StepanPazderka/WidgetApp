//
//  WidgetAppApp.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
@main
struct WidgetAppApp: App {
	@ObservedObject var widgetSettingsRepository = WidgetSettingsRepository()
	
	init() {
		UIPageControl.appearance().currentPageIndicatorTintColor = .lightGray
		UIPageControl.appearance().pageIndicatorTintColor = UIColor.darkGray.withAlphaComponent(1)
	}

    var body: some Scene {
        WindowGroup {
			WidgetCarousel()
				.navigationTitle("EchoFrame")
        }
		.environmentObject(widgetSettingsRepository)
    }
}
