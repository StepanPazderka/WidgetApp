//
//  AppIntent.swift
//  WidgetAppWidget
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    @Parameter(title: "Widget")
    var content: WidgetSettings?

    init(content: WidgetSettings?) {
        self.content = content
    }

    init() {
    }
}

struct WidgetContentQuery: EntityQuery {
    func entities(for identifiers: [WidgetSettings.ID]) async throws -> [WidgetSettings] {
        let settings = await WidgetDataStore.fetchWidgetSettings()
        return settings.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [WidgetSettings] {
        await WidgetDataStore.fetchWidgetSettings()
    }

    func defaultResult() async -> WidgetSettings? {
        try? await suggestedEntities().first
    }
}
