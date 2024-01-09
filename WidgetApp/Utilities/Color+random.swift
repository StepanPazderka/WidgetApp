//
//  Color+random.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 09.01.2024.
//

import Foundation
import SwiftUI

extension Color {
    static let random = Self(uiColor: UIColor(hue: CGFloat.random(in: 0.0...1.0), saturation: CGFloat.random(in: 0.0...1.0), brightness: CGFloat.random(in: 0.0...1.0), alpha: 1.0))
}
