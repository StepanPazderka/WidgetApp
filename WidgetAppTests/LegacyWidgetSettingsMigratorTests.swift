import Foundation
import SwiftData
import SwiftUI
import Testing
@testable import WidgetApp

@MainActor
struct LegacyWidgetSettingsMigratorTests {
    @Test
    func migratesIndexedLegacyWidgetIntoAllFamilies() throws {
        let container = try makeInMemoryContainer()
        let legacyDefaults = FakeLegacyKeyValueStore([
            "5-widgetContent": "Hello",
            "5-systemSmall-widgetFontSize": 24.0,
            "5-systemSmall-widgetBold": true,
            "5-systemSmall-widgetColor": Color.red.rawValue,
        ])
        let icloudDefaults = FakeLegacyKeyValueStore()

        let migrator = LegacyWidgetSettingsMigrator(
            modelContainer: container,
            legacyDefaults: legacyDefaults,
            icloudDefaults: icloudDefaults
        )

        migrator.migrateIfNeeded()

        let results = try container.mainContext.fetch(FetchDescriptor<StoredWidgetSettings>())
        #expect(results.count == WidgetTypes.allCases.count)
        #expect(Set(results.map(\.widgetTypeRawValue)) == Set(WidgetTypes.allCases.map(\.rawValue)))

        let small = try #require(results.first(where: { $0.widgetTypeRawValue == WidgetTypes.systemSmall.rawValue }))
        #expect(small.widgetId == 5)
        #expect(small.text == "Hello")
        #expect(small.shouldBeBold == true)
        #expect(small.fontSize == 24.0)
        #expect(small.colorRawValue == Color.red.rawValue)

        let medium = try #require(results.first(where: { $0.widgetTypeRawValue == WidgetTypes.systemMedium.rawValue }))
        #expect(medium.text == "Hello")
        #expect(medium.shouldBeBold == false)
        #expect(medium.fontSize == 20.0)
    }

    @Test
    func migratesDefaultLegacyKeysForWidgetZero() throws {
        let container = try makeInMemoryContainer()
        let legacyDefaults = FakeLegacyKeyValueStore([
            "widgetContent": "Default content",
            "widgetFontSize": 18.0,
            "widgetBold": true,
            "widgetColor": Color.blue.rawValue,
        ])

        let migrator = LegacyWidgetSettingsMigrator(
            modelContainer: container,
            legacyDefaults: legacyDefaults,
            icloudDefaults: FakeLegacyKeyValueStore()
        )

        migrator.migrateIfNeeded()

        let results = try container.mainContext.fetch(FetchDescriptor<StoredWidgetSettings>())
        #expect(results.count == WidgetTypes.allCases.count)
        #expect(Set(results.map(\.widgetId)) == [0])
        #expect(results.allSatisfy { $0.text == "Default content" })
        #expect(results.allSatisfy { $0.fontSize == 18.0 })
        #expect(results.allSatisfy { $0.shouldBeBold == true })
        #expect(results.allSatisfy { $0.colorRawValue == Color.blue.rawValue })
    }

    @Test
    func doesNotDuplicateExistingSettingsAndCleansUpLegacyKeys() throws {
        let container = try makeInMemoryContainer()
        let existing = StoredWidgetSettings(
            widgetId: 3,
            widgetTypeRawValue: WidgetTypes.systemSmall.rawValue,
            text: "Existing",
            shouldBeBold: false,
            colorRawValue: Color.green.rawValue,
            fontSize: 14.0
        )
        container.mainContext.insert(existing)
        try container.mainContext.save()

        let legacyDefaults = FakeLegacyKeyValueStore([
            "3-widgetContent": "Migrated",
            "3-systemSmall-widgetFontSize": 22.0,
            "3-systemSmall-widgetBold": true,
            "3-systemSmall-widgetColor": Color.orange.rawValue,
            "smallWidgetSize": ["width": 10.0, "height": 10.0],
        ])
        let icloudDefaults = FakeLegacyKeyValueStore([
            "widgetContent": "Unused fallback"
        ])

        let migrator = LegacyWidgetSettingsMigrator(
            modelContainer: container,
            legacyDefaults: legacyDefaults,
            icloudDefaults: icloudDefaults
        )

        migrator.migrateIfNeeded()

        let results = try container.mainContext.fetch(FetchDescriptor<StoredWidgetSettings>())
        #expect(results.count == WidgetTypes.allCases.count)

        let smallMatches = results.filter {
            $0.widgetId == 3 && $0.widgetTypeRawValue == WidgetTypes.systemSmall.rawValue
        }
        #expect(smallMatches.count == 1)
        #expect(smallMatches[0].text == "Existing")

        #expect(legacyDefaults.object(forKey: "3-widgetContent") == nil)
        #expect(legacyDefaults.object(forKey: "3-systemSmall-widgetFontSize") == nil)
        #expect(legacyDefaults.object(forKey: "smallWidgetSize") == nil)
        #expect(icloudDefaults.object(forKey: "widgetContent") == nil)
    }

    private func makeInMemoryContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: StoredWidgetSettings.self, configurations: configuration)
    }
}

private final class FakeLegacyKeyValueStore: LegacyKeyValueStore {
    private var storage: [String: Any]

    init(_ storage: [String: Any] = [:]) {
        self.storage = storage
    }

    var allKeys: [String] {
        Array(storage.keys)
    }

    func object(forKey defaultName: String) -> Any? {
        storage[defaultName]
    }

    func removeObject(forKey defaultName: String) {
        storage.removeValue(forKey: defaultName)
    }

    func flush() { }
}
