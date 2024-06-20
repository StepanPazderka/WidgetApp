//
//  truncateText.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 20.06.2024.
//

import Foundation

func truncateText(_ text: String, toLength maxLength: Int) -> String {
	guard maxLength > 0 else { return "" }
	return text.count > maxLength ? String(text.prefix(maxLength)) + "..." : text
}
