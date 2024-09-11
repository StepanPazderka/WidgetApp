//
//  WidgetSizes.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 01.01.2024.
//

import Foundation

enum WidgetTypes: String, CaseIterable {
    case systemSmall
    case systemMedium
    case systemLarge
    case systemExtraLarge
    case accessoryRectangular
    case accessoryCircular
}

extension WidgetTypes: Codable { }
