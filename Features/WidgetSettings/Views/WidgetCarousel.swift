//
//  WidgetCarousel.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import SwiftUI
import WidgetKit
import SwiftData

struct WidgetCarousel: View {
    @State private var selectedWidgetNo = 0
    @State private var showingDeleteAlert = false
    @Environment(\.modelContext) private var modelContext
    @Query private var storedSettings: [StoredWidgetSettings]

    private var widgetIDs: [Int] {
        Array(Set(storedSettings.map(\.widgetId))).sorted()
    }

    var body: some View {
        VStack {
            TabView(selection: $selectedWidgetNo) {
                ForEach(widgetIDs, id: \.self) { widgetID in
                    WidgetSettingsView(selectedWidgetID: widgetID)
                        .tag(widgetID)
                }

                AddWidgetView(callback: { newWidgetID in
                    withAnimation {
                        selectedWidgetNo = newWidgetID
                    }
                })
                .tag(addWidgetTag)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .ignoresSafeArea(.all)

            Button(action: {
                showingDeleteAlert.toggle()
            }) {
                if !widgetIDs.isEmpty {
                    Label("Remove", systemImage: "trash")
                }
            }
        }
        .onAppear {
            if let firstWidgetID = widgetIDs.first {
                selectedWidgetNo = firstWidgetID
            }
        }
        .onChange(of: widgetIDs) { _, newWidgetIDs in
            if newWidgetIDs.contains(selectedWidgetNo) {
                return
            }

            if let firstWidgetID = newWidgetIDs.first {
                selectedWidgetNo = firstWidgetID
            } else {
                selectedWidgetNo = addWidgetTag
            }
        }
        .onOpenURL { url in
            if let host = url.host(), let id = Int(host) {
                withAnimation {
                    selectedWidgetNo = id
                }
            }
        }
        .alert(isPresented: $showingDeleteAlert, content: {
            Alert(title: Text("Are you sure you want to delete this widget settings?"), primaryButton: .default(Text("Yes"), action: {
                withAnimation {
                    deleteWidgetSettings(id: selectedWidgetNo)
                }
            }), secondaryButton: .cancel())
        })
        .background(Color(UIColor.tertiarySystemFill))
    }

    private var addWidgetTag: Int {
        (widgetIDs.max() ?? -1) + 1
    }

    private func deleteWidgetSettings(id: Int) {
        let matchingSettings = storedSettings.filter { $0.widgetId == id }
        for settings in matchingSettings {
            modelContext.delete(settings)
        }

        do {
            try modelContext.save()
            if let previousWidgetID = widgetIDs.last(where: { $0 < id }) {
                selectedWidgetNo = previousWidgetID
            } else if let firstWidgetID = widgetIDs.first(where: { $0 != id }) {
                selectedWidgetNo = firstWidgetID
            } else {
                selectedWidgetNo = addWidgetTag
            }
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            assertionFailure("Could not delete widget settings: \(error.localizedDescription)")
        }
    }
}

#Preview {
    WidgetCarousel()
}
