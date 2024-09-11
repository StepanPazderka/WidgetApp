//
//  WidgetSettingsViewSwiftData.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 08.08.2024.
//

import SwiftUI
import WidgetKit
import SwiftData

struct WidgetSettingsViewSwiftData: View {
	let icloudDefaults = NSUbiquitousKeyValueStore.default
	let iCloudChangePublisher = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
	@State var localDefaults: UserDefaults?
	
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	
	@EnvironmentObject private var widgetSettingsRepository: WidgetSettingsRepository
	@Environment(\.modelContext) private var context
	
	@State var widgetText = "This is a preview text that will be in the widget"
	@State var widgetBackgroundColor: Color = .white
	@State var widgetFontSize: CGFloat = 30.0
	@State var widgetPadding: CGFloat = 10.0
	@State var widgetIsBold = false
	
	@Binding var selectedWidgetFamily: WidgetTypes
	@Binding var selectedWidgetID: Int?
	
	@State var smallWidgetSize: CGSize = CGSize(width: 170, height: 170)
	@State var mediumWidgetSize: CGSize = CGSize(width: 364, height: 170)
	@State var largeWidgetSize: CGSize = CGSize(width: 364, height: 364)
	@State var extraLargeWidgetSize: CGSize = CGSize(width: 715, height: 364)
	
	@Query private var widgetSettings: [WidgetSettingsSwiftData]
	
	private var deviceType: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
	
	var anyWidgetValues: [String] {[
		widgetText.description,
		widgetBackgroundColor.description,
		widgetFontSize.description,
		widgetPadding.description,
		widgetIsBold.description
	]}
	
	var body: some View {
		VStack {
			VStack {
				TabView(selection: $selectedWidgetFamily) {
					WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
						.padding( deviceType == .pad ? 7 : 6)
						.frame(width: smallWidgetSize.width, height: smallWidgetSize.height)
						.background(widgetBackgroundColor)
						.foregroundStyle(widgetBackgroundColor.complementaryColor(for: widgetBackgroundColor))
						.font(.system(size: widgetFontSize))
						.fontWeight( widgetIsBold ? .bold : .regular)
						.clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
						.containerRelativeFrame(.horizontal)
						.tag(WidgetTypes.systemSmall)
					WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
						.padding(6)
						.frame(width: mediumWidgetSize.width, height: mediumWidgetSize.height)
						.background(widgetBackgroundColor)
						.foregroundStyle(widgetBackgroundColor.complementaryColor(for: widgetBackgroundColor))
						.font(.system(size: widgetFontSize))
						.fontWeight( widgetIsBold ? .bold : .regular)
						.clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
						.containerRelativeFrame(.horizontal)
						.tag(WidgetTypes.systemMedium)
					if deviceType == .pad {
						WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
							.padding(6)
							.frame(width: largeWidgetSize.width, height: largeWidgetSize.height)
							.background(widgetBackgroundColor)
							.foregroundStyle(widgetBackgroundColor.complementaryColor(for: widgetBackgroundColor))
							.font(.system(size: widgetFontSize))
							.fontWeight( widgetIsBold ? .bold : .regular)
							.clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
							.containerRelativeFrame(.horizontal)
							.tag(WidgetTypes.systemLarge)
						WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
							.padding(6)
							.frame(width: extraLargeWidgetSize.width, height: extraLargeWidgetSize.height)
							.background(widgetBackgroundColor)
							.foregroundStyle(widgetBackgroundColor.complementaryColor(for: widgetBackgroundColor))
							.font(.system(size: widgetFontSize))
							.fontWeight( widgetIsBold ? .bold : .regular)
							.clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
							.containerRelativeFrame(.horizontal)
							.tag(WidgetTypes.systemExtraLarge)
					}
					WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
						.padding(2)
						.frame(width: 180, height: 85)
						.background(.black.opacity(0.5))
						.foregroundStyle(.white)
						.colorMultiply(.white)
						.grayscale(1.0)
						.font(.system(size: widgetFontSize))
						.fontWeight( widgetIsBold ? .bold : .regular)
						.clipShape(RoundedRectangle(cornerSize: CGSizeMake(10, 10)))
						.containerRelativeFrame(.horizontal)
						.tag(WidgetTypes.accessoryRectangular)
					WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
						.padding(2)
						.frame(width: 72, height: 72)
						.background(.black.opacity(0.5))
						.foregroundStyle(.white)
						.colorMultiply(.white)
						.grayscale(1.0)
						.font(.system(size: widgetFontSize))
						.fontWeight( widgetIsBold ? .bold : .regular)
						.clipShape(RoundedRectangle(cornerSize: CGSizeMake(10, 10)))
						.containerRelativeFrame(.horizontal)
						.tag(WidgetTypes.accessoryCircular)
				}
				.padding(0)
				.padding([.top], -150)
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
				.frame(maxWidth: .infinity)
				.frame(height: deviceType == .pad ? 450 : 300)
				.onChange(of: selectedWidgetFamily) { oldValue, newValue in
					if let selectedWidgetID {
						loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
					}
				}
				.onAppear {
					if let selectedWidgetID {
						loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
					}
				}
				.animation(.easeInOut(duration: 4), value: selectedWidgetFamily)
			}.onTapGesture {
				self.hideKeyboard()
			}
			
			VStack {
				if horizontalSizeClass == .compact {
					VStack {
						TextEditor(text: $widgetText)
							.padding(15)
							.scrollContentBackground(.hidden)
							.background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
							.clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
							.frame(height: 150)
						VStack {
							if deviceType == .pad {
								Slider(value: $widgetFontSize, in: 10...80, step: 1)
							} else {
								Slider(value: $widgetFontSize, in: 5...30, step: 1)
							}
							Spacer()
								.frame(height: 20)
								.onTapGesture {
									self.hideKeyboard()
								}
							Toggle(isOn: $widgetIsBold, label: {
								Text("Should be bold")
							})
							.onTapGesture {
								self.hideKeyboard()
							}
							ColorPicker("Background color", selection: $widgetBackgroundColor)
						}
						.padding([.leading, .trailing], 20)
					}
				} else {
					HStack {
						TextEditor(text: $widgetText)
							.padding(15)
							.scrollContentBackground(.hidden)
							.background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
							.clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
							.frame(height: 150)
						VStack {
							if deviceType == .pad {
								Slider(value: $widgetFontSize, in: 10...80, step: 1)
							} else {
								Slider(value: $widgetFontSize, in: 5...30, step: 1)
							}
							Spacer()
								.frame(height: 20)
								.onTapGesture {
									self.hideKeyboard()
								}
							Toggle(isOn: $widgetIsBold, label: {
								Text("Should be bold")
							})
							.onTapGesture {
								self.hideKeyboard()
							}
							ColorPicker("Background color", selection: $widgetBackgroundColor)
						}
						.padding([.leading, .trailing], 20)
					}
				}
			}
			.padding(20)
			.frame(maxWidth: 800)
		}
		.onChange(of: selectedWidgetFamily, { oldValue, newValue in
			if let selectedWidgetID {
				loadSettings(forWidgetNo: selectedWidgetID, widgetSize: oldValue)
			}
		})
		.onChange(of: selectedWidgetID) { newValue, oldValue in
			if let selectedWidgetID {
				loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
			}
		}
		.onAppear {
			localDefaults = UserDefaults(suiteName: bundleID)
			
			if let selectedWidgetSettings = widgetSettings.first { $0.widgetId == $selectedWidgetID.wrappedValue } {
				if let selectedId = selectedWidgetSettings.widgetId {
					print(selectedId)
				}
			}
		}
		.padding([.top], -40)
		.onChange(of: anyWidgetValues) {
			if let selectedWidgetID {
				updateSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
				Task {
					widgetSettingsRepository.refreshWidgetSettings()
				}
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
			WidgetCenter.shared.reloadAllTimelines()
		}
		.onReceive(iCloudChangePublisher) { _ in
			self.widgetSettingsRepository.fetchWidgetSettings()
			if let selectedWidgetID {
				loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
			}
			WidgetCenter.shared.reloadAllTimelines()
		}
		.background(Color(UIColor.systemBackground))
		.padding([.bottom], 15)
		.ignoresSafeArea(edges: [.leading, .trailing, .bottom])
		.animation(.easeInOut(duration: 0.5), value: widgetFontSize)
		.animation(.easeInOut(duration: 1.5), value: widgetBackgroundColor)
	}
	
	func updateSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
		guard let widgetSettingsForCurrentIDandFamily = widgetSettings.first(where: { $0.widgetId == $selectedWidgetID.wrappedValue && $0.widgetFamily == $selectedWidgetFamily.wrappedValue }) else { return }
		
		let widgetSettingsForCurrentID = widgetSettings.filter({ $0.widgetId == $selectedWidgetID.wrappedValue })
		
		for widgetSettings in widgetSettingsForCurrentID {
			widgetSettings.text = widgetText
		}
		
		widgetSettingsForCurrentIDandFamily.color = widgetBackgroundColor.rawValue
		widgetSettingsForCurrentIDandFamily.fontSize = widgetFontSize
		widgetSettingsForCurrentIDandFamily.isBold = widgetIsBold
		
		Syncer(modelContainer: self.context.container).transferSwiftDataToLocalSettings()
		
		try? context.save()

		Task {
			WidgetCenter.shared.reloadAllTimelines()
		}
	}
	
	func transferOldSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
		let sharedDefaults = UserDefaults(suiteName: bundleID)
		
		if let oldContentData = sharedDefaults?.object(forKey: "widgetContent") as? String {
			sharedDefaults?.set(oldContentData, forKey: "\(forWidgetNo)-widgetContent")
			sharedDefaults?.removeObject(forKey: "widgetContent")
		}
		
		if let oldFontSize = sharedDefaults?.object(forKey: "widgetFontSize") as? CGFloat {
			sharedDefaults?.set(oldFontSize, forKey: "\(forWidgetNo)-\(widgetSize)-widgetFontSize")
			sharedDefaults?.removeObject(forKey: "widgetFontSize")
		}
		
		if let oldColorData = sharedDefaults?.object(forKey: "widgetColor") as? String {
			sharedDefaults?.set(oldColorData, forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor")
			sharedDefaults?.removeObject(forKey: "widgetColor")
		}
		
		if let oldShouldBeBold = sharedDefaults?.object(forKey: "widgetBold") as? Bool {
			sharedDefaults?.set(oldShouldBeBold, forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold")
			sharedDefaults?.removeObject(forKey: "widgetBold")
		}
	}
	
	func loadSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
		if let smallWidgetSize = localDefaults?.dictionary(forKey: "smallWidgetSize") as? [String: CGFloat] {
			self.smallWidgetSize.width = smallWidgetSize["width"] ?? 170
			self.smallWidgetSize.height = smallWidgetSize["height"] ?? 170
		}
		
		if let mediumWidgetSize = localDefaults?.dictionary(forKey: "mediumWidgetSize") as? [String: CGFloat] {
			self.mediumWidgetSize.width = mediumWidgetSize["width"] ?? 364
			self.mediumWidgetSize.height = mediumWidgetSize["height"] ?? 170
		}
		
		if let largeWidgetSize = localDefaults?.dictionary(forKey: "largeWidgetSize") as? [String: CGFloat] {
			self.largeWidgetSize.width = largeWidgetSize["width"] ?? 364
			self.largeWidgetSize.height = largeWidgetSize["height"] ?? 364
		}
		
		transferOldSettings(forWidgetNo: forWidgetNo, widgetSize: widgetSize)
		
		guard let selectedObject = widgetSettings.first(where: { $0.widgetId == $selectedWidgetID.wrappedValue && $0.widgetFamily == $selectedWidgetFamily.wrappedValue }) else { return }

		self.widgetText = selectedObject.text
		self.widgetFontSize = selectedObject.fontSize
		self.widgetIsBold = selectedObject.isBold
		let localColorData = selectedObject.color
		
		if let color = Color(rawValue: localColorData) {
			self.widgetBackgroundColor = color
		} else {
			self.widgetBackgroundColor = Color(uiColor: UIColor(hue: CGFloat.random(in: 0.0...1.0), saturation: CGFloat.random(in: 0.0...1.0), brightness: CGFloat.random(in: 0.0...1.0), alpha: 1.0))
		}
	}
}

#Preview {
	WidgetSettingsView(widgetText: "Preview Text", selectedWidgetFamily: .constant(.systemSmall), selectedWidgetID: .constant(0))
}

