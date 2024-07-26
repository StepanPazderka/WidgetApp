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

	@State var selectedWidgetNo: WidgetSettings?
	@State var showingDeleteAlert = false
	@State var showingAlert = false
	
    var body: some View {
		NavigationView {
			List(repo.widgetSettings.uniqued(on: \.id), selection: $selectedWidgetNo) { settings in
				NavigationLink(destination: WidgetSettingsView(selectedWidgetID: .constant(settings.id)), tag: settings, selection: $selectedWidgetNo) {
					HStack {
						Text(settings.text)
							.lineLimit(2)
					}
					.frame(minHeight: 50)
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
					self.selectedWidgetNo = repo.widgetSettings.first
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
					repo.deleteWidgetSettings(id: selectedWidgetNo.id)
					
					guard let firstID = repo.widgetSettings.first else { return }

					if selectedWidgetNo.id > firstID.id {
						self.selectedWidgetNo = repo.widgetSettings.first(where: { $0.id == $0.id - 1 })
					} else {
						self.selectedWidgetNo = firstID
					}
					
					if self.selectedWidgetNo == nil {
						self.selectedWidgetNo = repo.widgetSettings.first
					}
					
					Task {
						WidgetCenter.shared.reloadAllTimelines()
					}
				}
			}), secondaryButton: .cancel())
		})
		.background(Color(UIColor.tertiarySystemFill))
		.onOpenURL { url in
			if let host = url.host() {
				if let id = Int(host) {
					withAnimation {
//						self.selectedWidgetNo = id
					}
				}
			}
		}
		.onReceive(iCloudChangePublisher, perform: { _ in
			repo.widgetSettings = repo.fetchWidgetSettings()
		})
    }
	
	func addWidget(id: Int) {
		if repo.widgetSettings.uniqued(on: \.id).count < 5 {
			let newID = repo.createNewWidgetSettings()
			self.selectedWidgetNo = repo.widgetSettings.first(where: { $0.id == newID })
		} else {
			showingAlert.toggle()
		}
	}
	
	func deleteWidgetSettings(id: Int) {
		self.showingDeleteAlert.toggle()
	}
}

#Preview {
    WidgetCarousel()
}
