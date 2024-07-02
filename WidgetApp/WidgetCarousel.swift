//
//  WidgetCarousel.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import SwiftUI
import WidgetKit

struct WidgetCarousel: View {
	@State var selectedWidgetNo = 0
	
	@State var showingDeleteAlert = false
	@EnvironmentObject var repo: WidgetSettingsRepository
	
    var body: some View {
		VStack {
			TabView(selection: $selectedWidgetNo) {
				ForEach(repo.widgetSettings.uniqued(on: \.id), id: \.id) { settings in
					WidgetSettingsView(selectedWidgetID: settings.id)
						.tag(settings.id)
				}

				AddWidgetView(callback: {
					withAnimation {
						if let lastID = repo.widgetSettings.last?.id {
							self.selectedWidgetNo = lastID
						}
					}
				})
				.tag(10)
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
			.ignoresSafeArea(.all)
			Button(action: {
				self.showingDeleteAlert.toggle()
			}) {
				if !repo.widgetSettings.isEmpty {
					Label("Remove", systemImage: "trash")
				}
			}
		}
		.onAppear {
			if let firstWidgetID = repo.widgetSettings.first?.id {
				selectedWidgetNo = firstWidgetID
			}
		}
		.onOpenURL { url in			
			if let host = url.host() {
				if let id = Int(host) {
					withAnimation {
						self.selectedWidgetNo = id
					}
				}
			}
		}
		.alert(isPresented: $showingDeleteAlert, content: {
			Alert(title: Text("Are you sure you want to delete this widget settings?"), primaryButton: .default(Text("Yes"), action: {
				withAnimation {
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
    }
}

struct CustomModel: Identifiable {
	let id = UUID()
	var value: String
}

#Preview {
    WidgetCarousel()
}
