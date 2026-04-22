//
//  WidgetSettingsSwiftData.swift
//  WidgetApp
//

import SwiftData
import SwiftUI
import WidgetKit

@Model
final class WidgetSettingsSwiftData {
    var widgetId: Int = 0
    var widgetFamilyRawValue: String = WidgetTypes.systemSmall.rawValue
    var text: String = ""
    var colorRawValue: String = Color.primary.rawValue
    var isBold: Bool = false
    var fontSize: Double = 20.0

    init(widgetId: Int, widgetFamily: WidgetTypes, text: String, color: Color, isBold: Bool, fontSize: CGFloat) {
        self.widgetId = widgetId
        self.widgetFamilyRawValue = widgetFamily.rawValue
        self.text = text
        self.colorRawValue = color.rawValue
        self.isBold = isBold
        self.fontSize = Double(fontSize)
    }

    var widgetFamily: WidgetTypes {
        WidgetTypes(rawValue: widgetFamilyRawValue) ?? .systemSmall
    }

    var color: Color {
        Color(rawValue: colorRawValue) ?? .primary
    }

    var widgetSettings: WidgetSettings {
        WidgetSettings(id: widgetId, text: text, shouldBeBold: isBold, color: color, fontSize: CGFloat(fontSize))
    }
}

extension WidgetFamily {
    var widgetType: WidgetTypes {
        switch self {
        case .systemSmall:
            return .systemSmall
        case .systemMedium:
            return .systemMedium
        case .systemLarge:
            return .systemLarge
        case .systemExtraLarge:
            return .systemExtraLarge
#if os(iOS)
        case .accessoryRectangular:
            return .accessoryRectangular
        case .accessoryCircular:
            return .accessoryCircular
#endif
        default:
            return .systemSmall
        }
    }
}

enum WidgetDataStore {
    static let schema = Schema([
        WidgetSettingsSwiftData.self
    ])

    static let configuration = ModelConfiguration(
        schema: schema,
        groupContainer: .identifier(bundleID),
        cloudKitDatabase: .private(cloudKitContainerID)
    )

    static func makeModelContainer() throws -> ModelContainer {
        try ModelContainer(for: schema, configurations: [configuration])
    }

    @MainActor
    static func fetchWidgetSettings() -> [WidgetSettings] {
        guard let container = try? makeModelContainer() else { return [] }
        let records = fetchRecords(in: container.mainContext)
        var seenIDs = Set<Int>()

        return records.compactMap { record in
            guard !seenIDs.contains(record.widgetId) else { return nil }
            seenIDs.insert(record.widgetId)
            return record.widgetSettings
        }
    }

    @MainActor
    static func fetchWidgetSettings(id: Int, widgetFamily: WidgetTypes) -> WidgetSettings? {
        guard let container = try? makeModelContainer() else { return nil }
        let records = fetchRecords(in: container.mainContext)
        return records.first { $0.widgetId == id && $0.widgetFamily == widgetFamily }?.widgetSettings
    }

    @MainActor
    private static func fetchRecords(in context: ModelContext) -> [WidgetSettingsSwiftData] {
        let descriptor = FetchDescriptor<WidgetSettingsSwiftData>(
            sortBy: [SortDescriptor(\.widgetId), SortDescriptor(\.widgetFamilyRawValue)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
