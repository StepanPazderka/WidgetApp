//
//  WidgetContent.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 08.01.2024.
//

import Foundation
import SwiftUI
import AppIntents
import Algorithms

struct WidgetSettings: AppEntity, Hashable {
    var id: String
    let text: String
    let shouldBeBold: Bool
    let color: Color
    let fontSize: CGFloat
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "WidgetContent"
    static var defaultQuery = WidgetQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(text)")
    }
}

struct WidgetQuery: EntityQuery {
    func entities(for identifiers: [WidgetSettings.ID]) async throws -> [WidgetSettings] {
        WidgetContentProvider().loadWidgetSettings()
    }
    
    func suggestedEntities() async throws -> [WidgetSettings] {
        WidgetContentProvider().loadWidgetSettings().uniqued { $0.id }
    }
    
    func defaultResult() async -> WidgetSettings? {
        try? await suggestedEntities().first
    }
}
