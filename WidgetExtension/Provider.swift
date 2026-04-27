//
//  Provder.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 01.07.2024.
//

import SwiftUI
import WidgetKit
import SwiftData

enum SharedWidgetStore {
    static let container: ModelContainer = {
        do {
            return try makeLocalContainer()
        } catch {
            fatalError("Could not create widget model container: \(error.localizedDescription)")
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
        print("WidgetExtension Provider: using shared local SwiftData store")
        return container
    }
}

struct Provider: AppIntentTimelineProvider {
    private let sharedDefaults = UserDefaults(suiteName: bundleID)

    // MARK: - Placeholder for when previewing widget when on homescreen
    func placeholder(in context: Context) -> WidgetSettings {
        WidgetSettings(
            text: "Your text will be displayed here",
            shouldBeBold: false,
            color: .primary,
            fontSize: 20.0
        )
    }

    // MARK: - Snapshot when updating timeline
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WidgetSettings {
        makeEntry(for: configuration, in: context)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WidgetSettings> {
        let entry = makeEntry(for: configuration, in: context)
        return Timeline(entries: [entry], policy: .never)
    }

    private func makeEntry(for configuration: ConfigurationAppIntent, in context: Context) -> WidgetSettings {
        let id = configuration.content.id
        let widgetType = widgetType(for: context.family)
        persistDisplaySize(for: context)
        let settings = loadStoredSettings(id: id, widgetType: widgetType)

        return WidgetSettings(
            id: id,
            text: settings?.text ?? "Preview text",
            shouldBeBold: settings?.shouldBeBold ?? false,
            color: Color(rawValue: settings?.colorRawValue ?? "") ?? .primary,
            fontSize: CGFloat(settings?.fontSize ?? 20.0)
        )
    }

    private func loadStoredSettings(id: Int, widgetType: WidgetTypes) -> StoredWidgetSettings? {
        let context = ModelContext(SharedWidgetStore.container)
        let widgetTypeRawValue = widgetType.rawValue

        let exactDescriptor = FetchDescriptor<StoredWidgetSettings>(
            predicate: #Predicate { item in
                item.widgetId == id && item.widgetTypeRawValue == widgetTypeRawValue
            }
        )

        if let exactMatch = try? context.fetch(exactDescriptor).first {
            return exactMatch
        }

        let fallbackDescriptor = FetchDescriptor<StoredWidgetSettings>(
            predicate: #Predicate { item in
                item.widgetId == id
            }
        )

        return try? context.fetch(fallbackDescriptor).first
    }

    private func widgetType(for family: WidgetFamily) -> WidgetTypes {
        switch family {
        case .systemSmall:
            return .systemSmall
        case .systemMedium:
            return .systemMedium
        case .systemLarge:
            return .systemLarge
        case .systemExtraLarge:
            return .systemExtraLarge
        case .accessoryRectangular:
            return .accessoryRectangular
        case .accessoryCircular:
            return .accessoryCircular
        default:
            return .systemSmall
        }
    }

    private func persistDisplaySize(for context: Context) {
        let sizeKey: String

        switch context.family {
        case .systemSmall:
            sizeKey = "smallWidgetSize"
        case .systemMedium:
            sizeKey = "mediumWidgetSize"
        case .systemLarge:
            sizeKey = "largeWidgetSize"
        case .systemExtraLarge:
            sizeKey = "extraLargeWidgetSize"
        default:
            return
        }

        let size: [String: CGFloat] = [
            "width": context.displaySize.width,
            "height": context.displaySize.height
        ]
        sharedDefaults?.set(size, forKey: sizeKey)
    }
}
