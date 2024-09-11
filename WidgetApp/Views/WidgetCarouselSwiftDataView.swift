//
//  WidgetCarouselView2.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 30.07.2024.
//

import SwiftUI
import SwiftData

struct WidgetCarouselSwiftDataView: View {
	@Query(sort: \WidgetSettingsSwiftData.widgetId) private var widgetSettings: [WidgetSettingsSwiftData]
	
	@Environment(\.modelContext) private var context
	
	@Binding var selectedWidgetNo: Int?
	@Binding var selectedWidgetFamily: WidgetTypes
			
	var body: some View {
		NavigationSplitView {
			VStack {
				SyncStatusView()
				List(widgetSettings.uniqued(on: \.widgetId), id: \.widgetId, selection: $selectedWidgetNo) { widgetSettings in
					@Bindable var widgetSettings = widgetSettings
					NavigationLink(value: widgetSettings) {
						Text(widgetSettings.text)
					}
					.tag(widgetSettings.widgetId ?? 0)
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button(role: .destructive) {
							Task {
								if let id = widgetSettings.widgetId {
									deleteWidgetSettings(forNumber: id)
								}
							}
						} label: {
							Text("Delete")
						}
					}
					.contextMenu {
						VStack {
							Button(role: .destructive) {
								Task {
									if let id = widgetSettings.widgetId {
										deleteWidgetSettings(forNumber: id)
									}
								}
							} label: {
								Label("Delete", systemImage: "trash")
							}
						}
					}
				}
				Button("Delete entire db") {
					deleteEntireDB()
				}
			}
			.toolbar {
				Button {
					Task {
						createNewWidgetSettings()
					}
				} label: {
					Image(systemName: "plus")
				}
			}
		} detail: {
			NavigationStack {
				if let selectedWidgetNo {
					WidgetSettingsViewSwiftData(selectedWidgetFamily: $selectedWidgetFamily, selectedWidgetID: $selectedWidgetNo)
				}
			}
		}
		.onAppear {
		}
	}
	
	func createNewWidgetSettings() {
		let widgetContent = "This is a preview text that will be in the widget"
		let widgetShouldBeBold = false
		let widgetColor: Color = .primary
		let widgetFontSize = 20.0
		
		var newWidgetID: Int?
		
		if let lastWidgetID = widgetSettings.last?.widgetId {
			newWidgetID = lastWidgetID + 1
		} else {
			newWidgetID = 0
		}
		
		guard let newWidgetID else { return }
		
		for widgetType in WidgetTypes.allCases {
			let newWidgetSettings = WidgetSettingsSwiftData(widgetId: newWidgetID, color: widgetColor, text: widgetContent, isBold: widgetShouldBeBold, fontSize: widgetFontSize, widgetFamily: widgetType)
			context.insert(newWidgetSettings)
		}
		try? context.save()
	}
	
	func deleteWidgetSettings(forNumber id: Int) {
		let settingsToDelete = widgetSettings.filter { $0.widgetId == id }
		
		for settings in settingsToDelete {
			self.context.delete(settings)
		}
		try? self.context.save()
	}
	
	func deleteEntireDB() {
		for settings in widgetSettings {
			context.delete(settings)
		}
		
		try? context.save()
	}
}

#Preview {
	WidgetCarouselSwiftDataView(selectedWidgetNo: .constant(0), selectedWidgetFamily: .constant(.systemSmall))
}
