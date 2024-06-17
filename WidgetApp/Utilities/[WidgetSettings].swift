//
//  [WidgetSettings].swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 31.05.2024.
//

import Foundation
import Algorithms

extension Array: CustomStringConvertible where Element == WidgetSettings {
	var description: String {
		return "Number if unique settings \(self.count), number of detected uniquie IDs \(self.uniqued(on: \.id).count), array of unique IDs: \(self.uniqued(on: \.id))"
	}
}
