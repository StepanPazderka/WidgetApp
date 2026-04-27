//
//  View+hideKeyboard.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 05.01.2024.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
