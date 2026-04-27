//
//  AddWidgetView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import SwiftUI
import SwiftData

struct AddWidgetView: View {
    @Query private var storedSettings: [StoredWidgetSettings]
    var callback: ((Int) -> Void)?
    @State private var showingAlert = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Button(action: { addWidget() }) {
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

    private var uniqueWidgetIDs: [Int] {
        Array(Set(storedSettings.map(\.widgetId))).sorted()
    }

    private func addWidget() {
        guard uniqueWidgetIDs.count < 5 else {
            showingAlert.toggle()
            return
        }

        let newWidgetID = (uniqueWidgetIDs.max() ?? -1) + 1
        let storedSettings = StoredWidgetSettings.makeDefault(withWidgetId: newWidgetID)

        modelContext.insert(storedSettings)

        do {
            try modelContext.save()
            callback?(newWidgetID)
        } catch {
            assertionFailure("Could not create widget settings: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddWidgetView()
}
