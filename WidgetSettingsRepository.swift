//
//  WidgetSettingsRepository.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 15.05.2024.
//

import SwiftData
import SwiftUI
import WidgetKit

@MainActor
class WidgetSettingsRepository: ObservableObject {
    @Published var widgetSettings: [WidgetSettings] = []

    private let container: ModelContainer
    private let context: ModelContext

    init() {
        do {
            let container = try WidgetDataStore.makeModelContainer()
            self.container = container
            self.context = container.mainContext
            migrateLegacyDefaultsIfNeeded()
            widgetSettings = loadWidgetSettings()
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }

    func loadWidgetSettings() -> [WidgetSettings] {
        let records = fetchRecords()
        var seenIDs = Set<Int>()

        let settings = records.compactMap { record -> WidgetSettings? in
            guard !seenIDs.contains(record.widgetId) else { return nil }
            seenIDs.insert(record.widgetId)
            return record.widgetSettings
        }

        widgetSettings = settings
        return settings
    }

    func widgetSettings(for id: Int, widgetFamily: WidgetTypes) -> WidgetSettings? {
        fetchRecord(id: id, widgetFamily: widgetFamily)?.widgetSettings
    }

    func updateWidgetSettings(id: Int, widgetFamily: WidgetTypes, text: String, color: Color, isBold: Bool, fontSize: CGFloat) {
        let matchingIDRecords = fetchRecords().filter { $0.widgetId == id }
        let record = matchingIDRecords.first { $0.widgetFamily == widgetFamily }

        for record in matchingIDRecords {
            record.text = text
        }

        if let record {
            record.colorRawValue = color.rawValue
            record.isBold = isBold
            record.fontSize = Double(fontSize)
        } else {
            context.insert(WidgetSettingsSwiftData(
                widgetId: id,
                widgetFamily: widgetFamily,
                text: text,
                color: color,
                isBold: isBold,
                fontSize: fontSize
            ))
        }

        saveAndRefreshTimelines()
    }

    func createNewWidgetSettings() {
        let records = fetchRecords()
        let newWidgetID = (records.map(\.widgetId).max() ?? -1) + 1
        let widgetContent = "Preview content"
        let widgetShouldBeBold = false
        let widgetColor: Color = .primary
        let widgetFontSize: CGFloat = 20.0

        for widgetType in WidgetTypes.allCases {
            context.insert(WidgetSettingsSwiftData(
                widgetId: newWidgetID,
                widgetFamily: widgetType,
                text: widgetContent,
                color: widgetColor,
                isBold: widgetShouldBeBold,
                fontSize: widgetFontSize
            ))
        }

        saveAndRefreshTimelines()
    }

    func deleteWidgetSettings(id: Int) {
        for record in fetchRecords().filter({ $0.widgetId == id }) {
            context.delete(record)
        }

        saveAndRefreshTimelines()
    }

    private func saveAndRefreshTimelines() {
        do {
            try context.save()
            widgetSettings = loadWidgetSettings()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to save widget settings: \(error)")
        }
    }

    private func fetchRecords() -> [WidgetSettingsSwiftData] {
        let descriptor = FetchDescriptor<WidgetSettingsSwiftData>(
            sortBy: [SortDescriptor(\.widgetId), SortDescriptor(\.widgetFamilyRawValue)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    private func fetchRecord(id: Int, widgetFamily: WidgetTypes) -> WidgetSettingsSwiftData? {
        let widgetFamilyRawValue = widgetFamily.rawValue
        let descriptor = FetchDescriptor<WidgetSettingsSwiftData>(
            predicate: #Predicate { record in
                record.widgetId == id && record.widgetFamilyRawValue == widgetFamilyRawValue
            }
        )

        return try? context.fetch(descriptor).first
    }

    private func migrateLegacyDefaultsIfNeeded() {
        guard fetchRecords().isEmpty else { return }
        guard let localDefaults = UserDefaults(suiteName: bundleID) else { return }

        var didMigrate = false

        for id in 0...100 {
            let widgetContent = localDefaults.object(forKey: "\(id)-widgetContent") as? String

            for widgetType in WidgetTypes.allCases {
                let widgetFontSize = localDefaults.object(forKey: "\(id)-\(widgetType)-widgetFontSize") as? CGFloat
                let widgetIsBold = localDefaults.object(forKey: "\(id)-\(widgetType)-widgetBold") as? Bool
                let widgetColorRawValue = localDefaults.object(forKey: "\(id)-\(widgetType)-widgetColor") as? String

                guard widgetContent != nil || widgetFontSize != nil || widgetIsBold != nil || widgetColorRawValue != nil else { continue }

                let color = widgetColorRawValue.flatMap(Color.init(rawValue:)) ?? .primary
                context.insert(WidgetSettingsSwiftData(
                    widgetId: id,
                    widgetFamily: widgetType,
                    text: widgetContent ?? "Preview content",
                    color: color,
                    isBold: widgetIsBold ?? false,
                    fontSize: widgetFontSize ?? 20.0
                ))
                didMigrate = true
            }
        }

        guard didMigrate else { return }

        do {
            try context.save()
        } catch {
            print("Failed to migrate legacy widget settings: \(error)")
        }
    }
}
