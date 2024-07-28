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
	
	@State var selectedWidgetID: Int? = 0
	@State var selectedWidgetFamily: WidgetTypes = .systemSmall
	
	init() {
		UIPageControl.appearance().currentPageIndicatorTintColor = .lightGray
		UIPageControl.appearance().pageIndicatorTintColor = UIColor.darkGray.withAlphaComponent(1)
	}

    var body: some Scene {
        WindowGroup {
			WidgetCarousel(selectedWidgetNo: $selectedWidgetID, selectedWidgetFamily: $selectedWidgetFamily)
				.onOpenURL { url in
					if let host = url.host() {
						if let id = Int(host) {
							withAnimation {
								self.selectedWidgetID = id
							}
						}
					}
					
					if let widgetType = WidgetTypes(rawValue: url.pathComponents[1]) {
						withAnimation {
							self.selectedWidgetFamily = widgetType
						}
					}
				}
				.navigationTitle("EchoFrame")
				.onChange(of: selectedWidgetFamily) { newValue, oldValue in
					print("New Value: \(newValue), Old Value: \(oldValue)")
				}
        }
		.environmentObject(widgetSettingsRepository)
    }
}
