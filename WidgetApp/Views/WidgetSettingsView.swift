//
//  ContentView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
import WidgetKit
import UIKit
import RegexBuilder

struct WidgetSettingsView: View {
    let icloudDefaults = NSUbiquitousKeyValueStore.default
    let iCloudChangePublisher = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
	@State var localDefaults: UserDefaults?
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
	
	@Environment(\.widgetSettingsRepository) private var widgetSettingsRepository
    
    @State var widgetText = "This is a preview text that will be in the widget"
	@State var widgetBackgroundColor: Color = .white
    @State var widgetFontSize: CGFloat = 30.0
    @State var widgetPadding: CGFloat = 10.0
    @State var widgetIsBold = false
	
    @State var selectedWidgetFamily: WidgetTypes = .systemSmall
    @State var selectedWidgetID: Int
    
    @State var smallWidgetSize: CGSize = CGSize(width: 170, height: 170)
    @State var mediumWidgetSize: CGSize = CGSize(width: 364, height: 170)
    @State var largeWidgetSize: CGSize = CGSize(width: 364, height: 364)
    @State var extraLargeWidgetSize: CGSize = CGSize(width: 715, height: 364)
		    
    private var deviceType: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var body: some View {
		VStack {
			VStack {
				TabView(selection: $selectedWidgetFamily) {
					WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
						.padding( deviceType == .pad ? 4 : 6)
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
				.onOpenURL { url in
					if let widgetType = WidgetTypes(rawValue: url.pathComponents[1]) {
						withAnimation {
							self.selectedWidgetFamily = widgetType
						}
					}
				}
				.padding(0)
				.padding([.top], -150)
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
				.frame(maxWidth: .infinity)
				.frame(height: deviceType == .pad ? 450 : 300)
				.onChange(of: selectedWidgetFamily) { oldValue, newValue in
					print(newValue.rawValue)
					loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
				}
				.onAppear {
					loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
				}
				.animation(.easeInOut(duration: 4), value: selectedWidgetFamily)
			}.onTapGesture {
				self.hideKeyboard()
			}
			
			VStack {
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
			.padding(20)
			.frame(maxWidth: 800)
		}
//		.padding()
		.padding([.top], -40)
		.onAppear {
			localDefaults = UserDefaults(suiteName: bundleID)
		}
		.onChange(of: widgetText) {
			updateSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
		}
		.onChange(of: widgetIsBold) {
			updateSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
		}
		.onChange(of: widgetBackgroundColor) {
			updateSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
		}
		.onChange(of: widgetFontSize) {
			updateSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
		}
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
			WidgetCenter.shared.reloadAllTimelines()
		}
		.onReceive(iCloudChangePublisher, perform: { _ in
			loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
			WidgetCenter.shared.reloadAllTimelines()
		})
		.background(Color(UIColor.systemBackground))
//		.background(Color(.red))
//		.padding(5)
		.padding([.bottom], 15)
		.ignoresSafeArea(edges: [.leading, .trailing, .bottom])
    }
    
    func updateSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
        localDefaults?.set(widgetText, forKey: "\(forWidgetNo)-widgetContent")
        localDefaults?.set(widgetFontSize, forKey: "\(forWidgetNo)-\(widgetSize)-widgetFontSize")
        localDefaults?.set(widgetBackgroundColor.rawValue, forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor")
        localDefaults?.set(widgetIsBold, forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold")
        
        icloudDefaults.set(widgetText, forKey: "\(forWidgetNo)-widgetContent")
        icloudDefaults.set(widgetBackgroundColor.rawValue, forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor")
        icloudDefaults.set(widgetIsBold, forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold")
		localDefaults?.set(widgetFontSize, forKey: "\(forWidgetNo)-\(widgetSize)-widgetFontSize")
        
		icloudDefaults.synchronize()
		
		WidgetCenter.shared.reloadAllTimelines()
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
        
        let localWidgetContent = localDefaults?.object(forKey: "\(forWidgetNo)-widgetContent") as? String
        let localFontSize = localDefaults?.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetFontSize") as? CGFloat
        let localIsBold = localDefaults?.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold") as? Bool
        let localColorData = localDefaults?.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor") as? String
        
        let iCloudWidgetContent = icloudDefaults.object(forKey: "\(forWidgetNo)-widgetContent") as? String
        let iCloudWidgetIsBold = icloudDefaults.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold") as? Bool
        let iCloudWidgetColorData = icloudDefaults.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor") as? String
        
        if let iCloudWidgetContent {
            localDefaults?.set(iCloudWidgetContent, forKey: "\(forWidgetNo)-widgetContent")
        }
        
        if let iCloudWidgetIsBold {
            localDefaults?.set(iCloudWidgetIsBold, forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold")
        }
        
        if let iCloudWidgetColorData {
            localDefaults?.set(iCloudWidgetColorData, forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor")
        }
                
        if let iCloudWidgetColorData {
            if let color = Color(rawValue: iCloudWidgetColorData) {
                self.widgetBackgroundColor = color
            }
        } else if let localColorData {
            if let color = Color(rawValue: localColorData) {
                self.widgetBackgroundColor = color
            }
        } else {
            self.widgetBackgroundColor = Color(uiColor: UIColor(hue: CGFloat.random(in: 0.0...1.0), saturation: CGFloat.random(in: 0.0...1.0), brightness: CGFloat.random(in: 0.0...1.0), alpha: 1.0))
        }
        
        self.widgetIsBold = iCloudWidgetIsBold ?? localIsBold ?? false
        self.widgetText = iCloudWidgetContent ?? localWidgetContent ?? "This is a preview text that will be in the widget"
        if let localWidgetContent, localWidgetContent.isEmpty {
            self.widgetText = "This is a preview text that will be in the widget"
        }
        
        withAnimation {
            self.widgetFontSize = localFontSize ?? 15.0
        }
    }
}

#Preview {
	WidgetSettingsView(widgetText: "Preview Text", selectedWidgetID: 0)
}
