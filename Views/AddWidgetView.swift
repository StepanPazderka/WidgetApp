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
    }
	
	func addWidget(id: Int) {
		repo.createNewWidgetSettings()
		
		if callback != nil {
			callback!()
		}
	}
}

#Preview {
    AddWidgetView()
}
