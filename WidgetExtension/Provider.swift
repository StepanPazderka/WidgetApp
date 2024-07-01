//
//  Provder.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 01.07.2024.
//

import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
	let localDefaults = UserDefaults(suiteName: bundleID)
	let icloudDefaults = NSUbiquitousKeyValueStore.default
	
	// MARK: - Placeholder for when previewing widget when on homescreen
	func placeholder(in context: Context) -> WidgetSettings {
		let fontSize = localDefaults?.object(forKey: "widgetFontSize") as? CGFloat
		
		return WidgetSettings(text: "Your text will be displayed here", shouldBeBold: false, color: .primary, fontSize: fontSize ?? 20.0)
	}
	
	// MARK: - Snapshot when updating timeline
	func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WidgetSettings {
		let id = configuration.content.id
		
		let text = localDefaults?.object(forKey: "\(id)-widgetContent") as? String
		var widgetType: WidgetTypes?
		
		if context.family == .systemSmall {
			widgetType = .systemSmall
			let smallWidgetSize: [String: CGFloat] = [
				"width": context.displaySize.width,
				"height": context.displaySize.height
			]
			localDefaults?.set(smallWidgetSize, forKey: "smallWidgetSize")
		} else if context.family == .systemMedium {
			widgetType = .systemMedium
			let mediumWidgetSize: [String: CGFloat] = [
				"width": context.displaySize.width,
				"height": context.displaySize.height
			]
			localDefaults?.set(mediumWidgetSize, forKey: "mediumWidgetSize")
		} else if context.family == .systemLarge {
			widgetType = .systemLarge
			let largeWidgetSize: [String: CGFloat] = [
				"width": context.displaySize.width,
				"height": context.displaySize.height
			]
			localDefaults?.set(largeWidgetSize, forKey: "largeWidgetSize")
		} else if context.family == .systemExtraLarge {
			widgetType = .systemExtraLarge
			let extraLargeWidgetSize: [String: CGFloat] = [
				"width": context.displaySize.width,
				"height": context.displaySize.height
			]
			localDefaults?.set(extraLargeWidgetSize, forKey: "extraLargeWidgetSize")
		}
#if os(iOS)
		if context.family == .accessoryRectangular {
			widgetType = .accessoryRectangular
		} else if context.family == .accessoryCircular {
			widgetType = .accessoryCircular
		}
#endif
		
		let fontSize = localDefaults?.object(forKey: "\(id)-\(widgetType?.rawValue ?? "systemSmall")-widgetFontSize") as? CGFloat
		let shouldBeBold = localDefaults?.object(forKey: "\(id)-\(widgetType?.rawValue ?? "systemSmall")-widgetBold") as? Bool
		let colorData = localDefaults?.object(forKey: "\(id)-\(widgetType?.rawValue ?? "systemSmall")-widgetColor") as? String
		var color: Color?
		
		if let colorData {
			color = Color(rawValue: colorData)
		}
		return WidgetSettings(id: id, text: text ?? "Preview text", shouldBeBold: shouldBeBold ?? false, color: color ?? .primary, fontSize: fontSize ?? 20.0)
	}
	
	func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WidgetSettings> {
		var entries: [WidgetSettings] = []
		
		var widgetType: WidgetTypes?
		if context.family == .systemSmall {
			widgetType = .systemSmall
			let smallWidgetSize: [String: CGFloat] = [
				"width": context.displaySize.width,
				"height": context.displaySize.height
			]
			localDefaults?.set(smallWidgetSize, forKey: "smallWidgetSize")
		} else if context.family == .systemMedium {
			widgetType = .systemMedium
			let mediumWidgetSize: [String: CGFloat] = [
				"width": context.displaySize.width,
				"height": context.displaySize.height
			]
			localDefaults?.set(mediumWidgetSize, forKey: "mediumWidgetSize")
		} else if context.family == .systemLarge {
			widgetType = .systemLarge
			let largeWidgetSize: [String: CGFloat] = [
				"width": context.displaySize.width,
				"height": context.displaySize.height
			]
			localDefaults?.set(largeWidgetSize, forKey: "largeWidgetSize")
		} else if context.family == .systemExtraLarge {
			widgetType = .systemExtraLarge
			let extraLargeWidgetSize: [String: CGFloat] = [
				"width": context.displaySize.width,
				"height": context.displaySize.height
			]
			localDefaults?.set(extraLargeWidgetSize, forKey: "extraLargeWidgetSize")
		}
#if os(iOS)
		if context.family == .accessoryRectangular {
			widgetType = .accessoryRectangular
			print("Rectangular: \(context.displaySize)")
		} else if context.family == .accessoryCircular {
			widgetType = .accessoryCircular
			print("Circular: \(context.displaySize)")
		}
#endif
		
		let id = configuration.content.id
		
		let widgetContent = localDefaults?.object(forKey: "\(id)-widgetContent") as? String
		let widgetFontSize = localDefaults?.object(forKey: "\(id)-\(widgetType?.rawValue ?? "systemSmall")-widgetFontSize") as? CGFloat
		let widgetBoldSetting = localDefaults?.object(forKey: "\(id)-\(widgetType?.rawValue ?? "systemSmall")-widgetBold") as? Bool
		let widgetColor = localDefaults?.object(forKey: "\(id)-\(widgetType?.rawValue ?? "systemSmall")-widgetColor") as? String
		var color: Color?
		
#if os(iOS)
		if context.family == .accessoryRectangular {
			print("Showing rectangular")
		}
#endif
		
		if let widgetColor {
			color = Color(rawValue: widgetColor)
		}
		let entry = WidgetSettings(id: id, text: widgetContent ?? "Couldn't load data", shouldBeBold: widgetBoldSetting ?? false, color: color ?? .primary, fontSize: widgetFontSize ?? 20.0)
		print(entry)
		entries.append(entry)
		return Timeline(entries: entries, policy: .never)
	}
}

