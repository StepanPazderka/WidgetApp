//
//  WidgetAppApp.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
import SwiftData

@main
struct WidgetAppApp: App {
	@ObservedObject var widgetSettingsRepository = WidgetSettingsRepository()
	
	@State var selectedWidgetID: Int?
	@State var selectedWidgetFamily: WidgetTypes = .systemSmall
			
	init() {
		UIPageControl.appearance().currentPageIndicatorTintColor = .lightGray
		UIPageControl.appearance().pageIndicatorTintColor = UIColor.darkGray.withAlphaComponent(1)
	}

    var body: some Scene {
        WindowGroup {
			WidgetCarouselSwiftDataView(selectedWidgetNo: $selectedWidgetID, selectedWidgetFamily: $selectedWidgetFamily)
				.tabItem { Label("SwiftData", systemImage: "list.star") }
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
        }
		.environmentObject(widgetSettingsRepository)
		.modelContainer(for: [WidgetSettingsSwiftData.self]) { result in
			switch result {
			case .success(let container):
				WidgetSettingsRepository.container = container
				print(container)
			case .failure(let error):
				print(error)
			}
		}
    }
}
