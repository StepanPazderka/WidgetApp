//
//  WidgetContentProvider.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 08.01.2024.
//

import Foundation
import Combine
import SwiftUI

class WidgetContentProvider: ObservableObject {
    @Published var widgetSettings: [WidgetSettings] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
    
    init() {
        widgetSettings = loadWidgetSettings()
        observeForUserDefaultChanges()
    }
    
    func observeForUserDefaultChanges() {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                guard let widgetSettings = self?.loadWidgetSettings() else { return }
                self?.widgetSettings = widgetSettings
            }
            .store(in: &cancellables)
    }
    
   func loadWidgetSettings() -> [WidgetSettings] {
        var returnArray = [WidgetSettings]()
        for WidgetNo in 0...100 {
            for widgetSize in WidgetTypes.allCases {                
                let textData = sharedDefaults?.object(forKey: "\(WidgetNo)-widgetContent") as? String
                let fontSize = sharedDefaults?.object(forKey: "\(WidgetNo)-\(widgetSize)-widgetFontSize") as? CGFloat
                let shouldBeBold = sharedDefaults?.object(forKey: "\(WidgetNo)-\(widgetSize)-widgetBold") as? Bool
                let colorData = sharedDefaults?.object(forKey: "\(WidgetNo)-\(widgetSize)-widgetColor") as? String
                
                if let textData, let colorData {
                    let widgetContent = WidgetSettings(id: String(describing: WidgetNo), text: textData, shouldBeBold: shouldBeBold ?? false, color: Color(rawValue: colorData) ?? .white, fontSize: fontSize ?? 10.0)
                    returnArray.append(widgetContent)
                }
            }
        }
        return returnArray
    }
    
    func createNewWidgetSettings(forWidgetNo: Int) {
        sharedDefaults?.set("Preview content", forKey: "\(forWidgetNo)-widgetContent")

        for widgetSize in WidgetTypes.allCases {
            sharedDefaults?.set(CGFloat(14.0), forKey: "\(forWidgetNo)-\(widgetSize)-widgetFontSize")
            sharedDefaults?.set(Color.random.rawValue, forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor")
            sharedDefaults?.set(false, forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold")
        }
    }
}
