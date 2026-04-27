//
//  WidgetAppApp.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
import IQKeyboardManagerSwift
import SwiftData

@main
struct WidgetApp: App {
    let modelContainer: ModelContainer

    init() {
        IQKeyboardManager.shared.enable = true
        UIPageControl.appearance().currentPageIndicatorTintColor = .lightGray
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.darkGray.withAlphaComponent(1)
        
        do {
            modelContainer = try Self.makeModelContainer()
            LegacyWidgetSettingsMigrator(modelContainer: modelContainer).migrateIfNeeded()
        } catch {
            fatalError("Could not create SwiftData model container: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            WidgetCarousel()
        }
        .modelContainer(modelContainer)
    }

    private static func makeModelContainer() throws -> ModelContainer {
        do {
            return try makeCloudKitBackedContainer()
        } catch {
            logCloudKitBootstrapError(error, source: "WidgetApp")
            return try makeLocalFallbackContainer()
        }
    }

    private static func makeCloudKitBackedContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            groupContainer: .identifier(bundleID),
            cloudKitDatabase: .private(cloudKitContainerID)
        )

        do {
            let container = try ModelContainer(
                for: StoredWidgetSettings.self,
                configurations: configuration
            )
            print("WidgetApp: using CloudKit-backed SwiftData store (\(cloudKitContainerID))")
            return container
        } catch {
            try resetPersistentStore(at: configuration.url)
            let container = try ModelContainer(
                for: StoredWidgetSettings.self,
                configurations: configuration
            )
            print("WidgetApp: using CloudKit-backed SwiftData store after resetting local store (\(cloudKitContainerID))")
            return container
        }
    }

    private static func makeLocalFallbackContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            groupContainer: .identifier(bundleID),
            cloudKitDatabase: .none
        )

        do {
            let container = try ModelContainer(
                for: StoredWidgetSettings.self,
                configurations: configuration
            )
            print("WidgetApp: CloudKit unavailable, using local SwiftData fallback store")
            return container
        } catch {
            try resetPersistentStore(at: configuration.url)
            let container = try ModelContainer(
                for: StoredWidgetSettings.self,
                configurations: configuration
            )
            print("WidgetApp: CloudKit unavailable, using reset local SwiftData fallback store")
            return container
        }
    }

    private static func logCloudKitBootstrapError(_ error: Error, source: String) {
        let nsError = error as NSError
        print("\(source): CloudKit-backed SwiftData bootstrap failed")
        print("\(source): error = \(error)")
        print("\(source): domain = \(nsError.domain)")
        print("\(source): code = \(nsError.code)")
        print("\(source): userInfo = \(nsError.userInfo)")
        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
            print("\(source): underlying domain = \(underlyingError.domain)")
            print("\(source): underlying code = \(underlyingError.code)")
            print("\(source): underlying userInfo = \(underlyingError.userInfo)")
        }
    }

    private static func resetPersistentStore(at storeURL: URL) throws {
        let fileManager = FileManager.default
        let companionURLs = [
            storeURL,
            storeURL.appendingPathExtension("shm"),
            storeURL.appendingPathExtension("wal")
        ]

        for url in companionURLs where fileManager.fileExists(atPath: url.path()) {
            try fileManager.removeItem(at: url)
        }
    }
}
