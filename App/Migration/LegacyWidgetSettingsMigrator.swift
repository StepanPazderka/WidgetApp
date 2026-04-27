//
//  LegacyWidgetSettingsMigrator.swift
//  WidgetApp
//
//  Created by Codex on 03.08.2025.
//

import Foundation
import SwiftData
import SwiftUI

final class LegacyWidgetSettingsMigrator {
    private let modelContainer: ModelContainer
    private let legacyDefaults: UserDefaults?
    private let icloudDefaults: NSUbiquitousKeyValueStore

    init(
        modelContainer: ModelContainer,
        legacyDefaults: UserDefaults? = UserDefaults(suiteName: bundleID),
        icloudDefaults: NSUbiquitousKeyValueStore = .default
    ) {
        self.modelContainer = modelContainer
        self.legacyDefaults = legacyDefaults
        self.icloudDefaults = icloudDefaults
    }

    func migrateIfNeeded() {
        guard let legacyDefaults else { return }

        let context = modelContainer.mainContext
        let existingSettings = (try? context.fetch(FetchDescriptor<StoredWidgetSettings>())) ?? []
        var importedKeys = Set(existingSettings.map { "\($0.widgetId)-\($0.widgetTypeRawValue)" })
        let legacyWidgetIDs = allLegacyWidgetIDs(
            from: legacyDefaults.dictionaryRepresentation().keys,
            and: icloudDefaults.dictionaryRepresentation.keys
        )

        var insertedSettings = false

        if hasLegacyDefaultWidgetValues(in: legacyDefaults) || hasLegacyDefaultWidgetValues(in: icloudDefaults) {
            insertedSettings = migrateLegacyWidget(
                id: 0,
                from: legacyDefaults,
                fallback: icloudDefaults,
                importedKeys: &importedKeys,
                into: context
            ) || insertedSettings
        }

        for widgetID in legacyWidgetIDs.sorted() {
            insertedSettings = migrateLegacyWidget(
                id: widgetID,
                from: legacyDefaults,
                fallback: icloudDefaults,
                importedKeys: &importedKeys,
                into: context
            ) || insertedSettings
        }

        guard insertedSettings else { return }

        do {
            try context.save()
            removeLegacyUserDefaultsValues(from: legacyDefaults, widgetIDs: legacyWidgetIDs)
            removeLegacyICloudValues(from: icloudDefaults, widgetIDs: legacyWidgetIDs)
        } catch {
            assertionFailure("Could not migrate legacy widget settings: \(error.localizedDescription)")
        }
    }

    private func migrateLegacyWidget(
        id: Int,
        from defaults: UserDefaults,
        fallback icloudDefaults: NSUbiquitousKeyValueStore,
        importedKeys: inout Set<String>,
        into context: ModelContext
    ) -> Bool {
        guard let text = legacyString(for: "\(id)-widgetContent", defaults: defaults, icloudDefaults: icloudDefaults)
            ?? (id == 0 ? legacyString(for: "widgetContent", defaults: defaults, icloudDefaults: icloudDefaults) : nil)
        else {
            return false
        }

        var insertedSettings = false

        for widgetType in WidgetTypes.allCases {
            let storageKey = "\(id)-\(widgetType.rawValue)"
            guard !importedKeys.contains(storageKey) else { continue }

            let fontSize = legacyDouble(
                for: "\(storageKey)-widgetFontSize",
                defaults: defaults,
                icloudDefaults: icloudDefaults
            ) ?? (id == 0 ? legacyDouble(for: "widgetFontSize", defaults: defaults, icloudDefaults: icloudDefaults) : nil) ?? 20.0
            let shouldBeBold = legacyBool(
                for: "\(storageKey)-widgetBold",
                defaults: defaults,
                icloudDefaults: icloudDefaults
            ) ?? (id == 0 ? legacyBool(for: "widgetBold", defaults: defaults, icloudDefaults: icloudDefaults) : nil) ?? false
            let colorRawValue = legacyString(
                for: "\(storageKey)-widgetColor",
                defaults: defaults,
                icloudDefaults: icloudDefaults
            ) ?? (id == 0 ? legacyString(for: "widgetColor", defaults: defaults, icloudDefaults: icloudDefaults) : nil) ?? Color.primary.rawValue

            let storedSettings = StoredWidgetSettings(
                widgetId: id,
                widgetTypeRawValue: widgetType.rawValue,
                text: text,
                shouldBeBold: shouldBeBold,
                colorRawValue: colorRawValue,
                fontSize: fontSize
            )
            context.insert(storedSettings)
            importedKeys.insert(storageKey)
            insertedSettings = true
        }

        return insertedSettings
    }

    private func allLegacyWidgetIDs(from defaultsKeys: some Sequence<String>, and icloudKeys: some Sequence<String>) -> Set<Int> {
        let keys = Array(defaultsKeys) + Array(icloudKeys)
        return Set(
            keys.compactMap { key -> Int? in
                guard key.hasSuffix("-widgetContent") else { return nil }
                return Int(key.replacingOccurrences(of: "-widgetContent", with: ""))
            }
        )
    }

    private func hasLegacyDefaultWidgetValues(in defaults: UserDefaults) -> Bool {
        defaults.object(forKey: "widgetContent") != nil
    }

    private func hasLegacyDefaultWidgetValues(in defaults: NSUbiquitousKeyValueStore) -> Bool {
        defaults.object(forKey: "widgetContent") != nil
    }

    private func legacyString(
        for key: String,
        defaults: UserDefaults,
        icloudDefaults: NSUbiquitousKeyValueStore
    ) -> String? {
        (defaults.object(forKey: key) as? String) ?? (icloudDefaults.object(forKey: key) as? String)
    }

    private func legacyBool(
        for key: String,
        defaults: UserDefaults,
        icloudDefaults: NSUbiquitousKeyValueStore
    ) -> Bool? {
        if let value = defaults.object(forKey: key) as? Bool {
            return value
        }
        if let value = defaults.object(forKey: key) as? NSNumber {
            return value.boolValue
        }
        if let value = icloudDefaults.object(forKey: key) as? Bool {
            return value
        }
        if let value = icloudDefaults.object(forKey: key) as? NSNumber {
            return value.boolValue
        }
        return nil
    }

    private func legacyDouble(
        for key: String,
        defaults: UserDefaults,
        icloudDefaults: NSUbiquitousKeyValueStore
    ) -> Double? {
        if let value = defaults.object(forKey: key) as? Double {
            return value
        }
        if let value = defaults.object(forKey: key) as? CGFloat {
            return Double(value)
        }
        if let value = defaults.object(forKey: key) as? NSNumber {
            return value.doubleValue
        }
        if let value = icloudDefaults.object(forKey: key) as? Double {
            return value
        }
        if let value = icloudDefaults.object(forKey: key) as? CGFloat {
            return Double(value)
        }
        if let value = icloudDefaults.object(forKey: key) as? NSNumber {
            return value.doubleValue
        }
        return nil
    }

    private func removeLegacyUserDefaultsValues(from defaults: UserDefaults, widgetIDs: Set<Int>) {
        let legacyKeys = [
            "smallWidgetSize",
            "mediumWidgetSize",
            "largeWidgetSize",
            "extraLargeWidgetSize",
            "widgetContent",
            "widgetFontSize",
            "widgetColor",
            "widgetBold"
        ]

        for key in legacyKeys {
            defaults.removeObject(forKey: key)
        }

        for widgetID in widgetIDs {
            defaults.removeObject(forKey: "\(widgetID)-widgetContent")

            for widgetType in WidgetTypes.allCases {
                let storageKey = "\(widgetID)-\(widgetType.rawValue)"
                defaults.removeObject(forKey: "\(storageKey)-widgetFontSize")
                defaults.removeObject(forKey: "\(storageKey)-widgetColor")
                defaults.removeObject(forKey: "\(storageKey)-widgetBold")
            }
        }
    }

    private func removeLegacyICloudValues(from defaults: NSUbiquitousKeyValueStore, widgetIDs: Set<Int>) {
        let legacyKeys = [
            "smallWidgetSize",
            "mediumWidgetSize",
            "largeWidgetSize",
            "extraLargeWidgetSize",
            "widgetContent",
            "widgetFontSize",
            "widgetColor",
            "widgetBold"
        ]

        for key in legacyKeys {
            defaults.removeObject(forKey: key)
        }

        for widgetID in widgetIDs {
            defaults.removeObject(forKey: "\(widgetID)-widgetContent")

            for widgetType in WidgetTypes.allCases {
                let storageKey = "\(widgetID)-\(widgetType.rawValue)"
                defaults.removeObject(forKey: "\(storageKey)-widgetFontSize")
                defaults.removeObject(forKey: "\(storageKey)-widgetColor")
                defaults.removeObject(forKey: "\(storageKey)-widgetBold")
            }
        }
        defaults.synchronize()
    }
}
