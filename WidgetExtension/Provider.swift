//
//  Provder.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 01.07.2024.
//

import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WidgetSettings {
        WidgetSettings(text: "Your text will be displayed here", shouldBeBold: false, color: .primary, fontSize: 20.0)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WidgetSettings {
        await entry(for: configuration, in: context)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WidgetSettings> {
        let entry = await entry(for: configuration, in: context)
        return Timeline(entries: [entry], policy: .atEnd)
    }

    private func entry(for configuration: ConfigurationAppIntent, in context: Context) async -> WidgetSettings {
        var selectedContent = configuration.content
        if selectedContent == nil {
            selectedContent = await WidgetDataStore.fetchWidgetSettings().first
        }
        guard let selectedContent else { return placeholder(in: context) }

        let widgetFamily = context.family.widgetType
        return await WidgetDataStore.fetchWidgetSettings(id: selectedContent.id, widgetFamily: widgetFamily) ?? WidgetSettings(id: selectedContent.id, text: "Couldn't load data", shouldBeBold: false, color: .primary, fontSize: 20.0)
    }
}
