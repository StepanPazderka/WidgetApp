//
//  Color+encode.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 22.12.2023.
//

import Foundation
import SwiftUI

extension Color: RawRepresentable {
    
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .gray
            return
        }
        do {
#if os(iOS)
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .gray
#elseif os(OSX)
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSColor ?? .gray
#endif
            self = Color(color)
        } catch {
            self = .gray
        }
    }

    public var rawValue: String {
        do {
#if os(iOS)
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
#elseif os(OSX)
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false) as Data
#endif

            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
    
    func complementaryColor(for color: Color) -> Color {
        // Convert the Color to UIColor to access its components
        let uiColor = UIColor(color)
        
        // Get the HSB components of the color
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        var white: CGFloat = 0
        var alpha2: CGFloat = 0
        uiColor.getWhite(&white, alpha: &alpha2)
        
        // Adjust the hue for the complementary color
        hue += 0.5 // Adding 180 degrees in HSB space
        if hue > 1 { hue -= 1 } // Ensuring hue stays within the range 0-1
        if white > 0.5 {
            white -= 0.5
        } else {
            white += 0.5
        }
        // Return the complementary color as a SwiftUI Color
        return Color(hue: hue, saturation: 0, brightness: white, opacity: 1.0)
    }
}
