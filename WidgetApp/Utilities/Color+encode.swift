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
}
