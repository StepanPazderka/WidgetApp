//
//  WidgetCarousel.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import SwiftUI
import WidgetKit

struct WidgetCarousel: View {
	@State var selectedWidgetNo: Int? = 0
	
	@State var showingDeleteAlert = false
	@EnvironmentObject var repo: WidgetSettingsRepository
	@State var showingAlert = false
	
    var body: some View {
		NavigationView {
			List(repo.widgetSettings.uniqued(on: \.id), selection: $selectedWidgetNo) { settings in
				NavigationLink(destination: WidgetSettingsView(selectedWidgetID: settings.id)) {
					HStack {
//							ZStack {
//								Text("\(settings.id)")
//							}
//							.opacity(0.5)
//							.padding(.trailing, 10)
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
		}
		.toolbar(.hidden)
		.animation(.easeInOut(duration: 0.1), value: repo.widgetSettings)
		.onAppear {
			if let firstWidgetID = repo.widgetSettings.first?.id {
				selectedWidgetNo = firstWidgetID
			}
		}
		.alert(isPresented: $showingDeleteAlert, content: {
			Alert(title: Text("Are you sure you want to delete this widget settings?"), primaryButton: .default(Text("Yes"), action: {
				withAnimation {
					guard let selectedWidgetNo else { return }
					repo.deleteWidgetSettings(id: selectedWidgetNo)
					
					guard let firstID = repo.widgetSettings.first?.id else { return }
					
					if selectedWidgetNo > firstID {
						self.selectedWidgetNo = selectedWidgetNo - 1
					} else {
						self.selectedWidgetNo = firstID
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
						self.selectedWidgetNo = id
					}
				}
			}
		}
    }
	
	func addWidget(id: Int) {
		if repo.widgetSettings.uniqued(on: \.id).count < 5 {
			let newID = repo.createNewWidgetSettings()
			self.selectedWidgetNo = newID
		} else {
			showingAlert.toggle()
		}
	}
	
	func deleteWidgetSettings(id: Int) {
		self.showingDeleteAlert.toggle()
		self.selectedWidgetNo = id
	}
}

#Preview {
    WidgetCarousel()
}
