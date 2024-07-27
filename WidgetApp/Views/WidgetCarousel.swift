//
//  WidgetCarousel.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import SwiftUI
import WidgetKit

struct WidgetCarousel: View {
	@EnvironmentObject var repo: WidgetSettingsRepository
	
	let iCloudChangePublisher = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)

	@Binding var selectedWidgetNo: Int?
	@Binding var selectedWidgetFamily: WidgetTypes?
	
	@State var showingDeleteAlert = false
	@State var showingAlert = false
	
    var body: some View {
		NavigationView {
			List(selection: $selectedWidgetNo) {
				ForEach(repo.widgetSettings.uniqued(on: \.id)) { settings in
					NavigationLink(destination: WidgetSettingsView(selectedWidgetID: $selectedWidgetNo)) {
						HStack {
							Text(settings.text)
								.lineLimit(2)
						}
						.frame(minHeight: 50)
						.tag(settings.id)
					}
					.swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
						Button {
							self.deleteWidgetSettings(id: settings.id)
						} label: {
							Label("Delete", systemImage: "trash")
						}
						.tint(.red)
					})
					.contextMenu(ContextMenu(menuItems: {
						Button {
							self.deleteWidgetSettings(id: settings.id)
						} label: {
							Label("Delete", systemImage: "trash")
						}
					}))
				}
			}
			.listStyle(.insetGrouped)
			.navigationTitle("Widget Settings")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						addWidget(id: repo.widgetSettings.count)
					} label: {
						Image(systemName: "plus")
					}
				}
			}
			.onAppear {
				if selectedWidgetNo == nil {
					self.selectedWidgetNo = repo.widgetSettings.first?.id
				}
			}
			
			Text("Select a widget settings to display")
		}
		.refreshable {
			NSUbiquitousKeyValueStore.default.synchronize()
		}
		.toolbar(.hidden)
		.animation(.easeInOut(duration: 0.1), value: repo.widgetSettings)
		.alert(isPresented: $showingDeleteAlert, content: {
			Alert(title: Text("Are you sure you want to delete this widget settings?"), primaryButton: .default(Text("Yes"), action: {
				withAnimation {
					guard let selectedWidgetNo else { return }
					repo.deleteWidgetSettings(id: selectedWidgetNo)
					
					guard let firstID = repo.widgetSettings.first else { return }

					if selectedWidgetNo > firstID.id {
						self.selectedWidgetNo = repo.widgetSettings.first(where: { $0.id == $0.id - 1 })?.id
					} else {
						self.selectedWidgetNo = firstID.id
					}
					
					if self.selectedWidgetNo == nil {
						self.selectedWidgetNo = repo.widgetSettings.first?.id
					}
					
					Task {
						WidgetCenter.shared.reloadAllTimelines()
					}
				}
			}), secondaryButton: .cancel())
		})
		.background(Color(UIColor.tertiarySystemFill))
		.onReceive(iCloudChangePublisher, perform: { _ in
			repo.widgetSettings = repo.fetchWidgetSettings()
		})
    }
	
	func addWidget(id: Int) {
		if repo.widgetSettings.uniqued(on: \.id).count < 5 {
			let newID = repo.createNewWidgetSettings()
			self.selectedWidgetNo = repo.widgetSettings.first(where: { $0.id == newID })?.id
		} else {
			showingAlert.toggle()
		}
	}
	
	func deleteWidgetSettings(id: Int) {
		self.showingDeleteAlert.toggle()
	}
}

#Preview {
	WidgetCarousel(selectedWidgetNo: .constant(0), selectedWidgetFamily: .constant(.systemSmall))
}
