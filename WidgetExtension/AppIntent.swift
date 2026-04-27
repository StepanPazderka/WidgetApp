//
//  AppIntent.swift
//  WidgetAppWidget
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import WidgetKit
import AppIntents
import SwiftData
import SwiftUI

private enum AppIntentWidgetStore {
    static let container: ModelContainer = {
        do {
            return try makeLocalContainer()
        } catch {
            fatalError("Could not create app intent model container: \(error.localizedDescription)")
        }
    }()

    private static func makeLocalContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            groupContainer: .identifier(bundleID),
            cloudKitDatabase: .none
        )
        let container = try ModelContainer(
            for: StoredWidgetSettings.self,
            configurations: configuration
        )
        print("WidgetExtension AppIntent: using shared local SwiftData store")
        return container
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    @Parameter(title: "Widget")
    var content: WidgetSettings

    init(content: WidgetSettings) {
        self.content = content
    }

    init() { }
}

struct WidgetContentQuery: EntityQuery {
    func entities(for identifiers: [WidgetSettings.ID]) async throws -> [WidgetSettings] {
        let allEntities = try loadWidgetEntities()
        return allEntities.filter { identifiers.contains($0.id) }
    }

    // MARK: - Settings selectable by user in UI
    func suggestedEntities() async throws -> [WidgetSettings] {
        try loadWidgetEntities()
    }

    func defaultResult() async -> WidgetSettings? {
        try? loadWidgetEntities().first
    }

    private func loadWidgetEntities() throws -> [WidgetSettings] {
        let context = ModelContext(AppIntentWidgetStore.container)
        let descriptor = FetchDescriptor<StoredWidgetSettings>()
        let settings = try context.fetch(descriptor)

        var uniqueSettingsByID: [Int: StoredWidgetSettings] = [:]
        for item in settings {
            if uniqueSettingsByID[item.widgetId] == nil {
                uniqueSettingsByID[item.widgetId] = item
            }
        }

        return uniqueSettingsByID
            .sorted { $0.key < $1.key }
            .map { id, item in
                WidgetSettings(
                    id: id,
                    text: item.text,
                    shouldBeBold: item.shouldBeBold,
                    color: Color(rawValue: item.colorRawValue) ?? .primary,
                    fontSize: CGFloat(item.fontSize)
                )
            }
    }
}
