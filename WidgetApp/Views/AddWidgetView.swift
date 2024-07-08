//
//  AddWidgetView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import SwiftUI

struct AddWidgetView: View {
	@EnvironmentObject var repo: WidgetSettingsRepository
	
	var callback: (() -> Void)?
	@State var showingAlert = false

    var body: some View {
		Button(action: { addWidget(id: repo.widgetSettings.count) } ) {
			VStack {
				Image(systemName: "plus")
					.resizable()
					.frame(width: 100, height: 100)
				Spacer().frame(height: 25)
				Text("Create new widget settings")
			}
		}
		.alert(isPresented: $showingAlert, content: {
			Alert(title: Text("Maximum number of widget settings reached"))
		})
    }
	
	func addWidget(id: Int) {
		if repo.widgetSettings.uniqued(on: \.id).count < 5 {
			repo.createNewWidgetSettings()
			
			if callback != nil {
				callback!()
			}
		} else {
			showingAlert.toggle()
		}
	}
}

#Preview {
    AddWidgetView()
}
