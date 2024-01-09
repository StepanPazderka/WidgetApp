//
//  ContentView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
import WidgetKit
import UIKit

struct ContentView: View {
    let icloudDefaults = NSUbiquitousKeyValueStore.default
    let iCloudChangePublisher = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State var textfielContent = "This is a preview text that will be in the widget"
    @State var backgroundColor = Color(.sRGB, red: 1.0, green: 1.0, blue: 1.0)
    @State var fontSize: CGFloat = 30.0
    @State var padding: CGFloat = 10.0
    @State var isBold = false
    
    @State var widgetStyleSelectedInPreview: WidgetTypes = .systemSmall
    @State var widgetNumber: Int = 0
    
    @State var smallWidgetSize: CGSize = CGSize(width: 170, height: 170)
    @State var mediumWidgetSize: CGSize = CGSize(width: 364, height: 170)
    @State var largeWidgetSize: CGSize = CGSize(width: 364, height: 364)
    @State var extraLargeWidgetSize: CGSize = CGSize(width: 715, height: 364)
    
    private var deviceType : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    TabView(selection: $widgetStyleSelectedInPreview) {
                        WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold, textPadding: $padding)
                            .padding( deviceType == .pad ? 4 : 6)
                            .frame(width: smallWidgetSize.width, height: smallWidgetSize.height)
                            .background(backgroundColor)
                            .foregroundStyle(backgroundColor.complementaryColor(for: backgroundColor))
                            .font(.system(size: fontSize))
                            .fontWeight( isBold ? .bold : .regular)
                            .clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
                            .containerRelativeFrame(.horizontal)
                            .tag(WidgetTypes.systemSmall)
                        WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold, textPadding: $padding)
                            .padding(6)
                            .frame(width: mediumWidgetSize.width, height: mediumWidgetSize.height)
                            .background(backgroundColor)
                            .foregroundStyle(backgroundColor.complementaryColor(for: backgroundColor))
                            .font(.system(size: fontSize))
                            .fontWeight( isBold ? .bold : .regular)
                            .clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
                            .containerRelativeFrame(.horizontal)
                            .tag(WidgetTypes.systemMedium)
                        if deviceType == .pad {
                            WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold, textPadding: $padding)
                                .padding(6)
                                .frame(width: largeWidgetSize.width, height: largeWidgetSize.height)
                                .background(backgroundColor)
                                .foregroundStyle(backgroundColor.complementaryColor(for: backgroundColor))
                                .font(.system(size: fontSize))
                                .fontWeight( isBold ? .bold : .regular)
                                .clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
                                .containerRelativeFrame(.horizontal)
                                .tag(WidgetTypes.systemLarge)
                            WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold, textPadding: $padding)
                                .padding(6)
                                .frame(width: extraLargeWidgetSize.width, height: extraLargeWidgetSize.height)
                                .background(backgroundColor)
                                .foregroundStyle(backgroundColor.complementaryColor(for: backgroundColor))
                                .font(.system(size: fontSize))
                                .fontWeight( isBold ? .bold : .regular)
                                .clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
                                .containerRelativeFrame(.horizontal)
                                .tag(WidgetTypes.systemExtraLarge)
                        }
                        WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold, textPadding: $padding)
                            .padding(2)
                            .frame(width: 180, height: 85)
                            .background(.black.opacity(0.5))
                            .foregroundStyle(.white)
                            .colorMultiply(.white)
                            .grayscale(1.0)
                            .font(.system(size: fontSize))
                            .fontWeight( isBold ? .bold : .regular)
                            .clipShape(RoundedRectangle(cornerSize: CGSizeMake(10, 10)))
                            .containerRelativeFrame(.horizontal)
                            .tag(WidgetTypes.accessoryRectangular)
                        WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold, textPadding: $padding)
                            .padding(2)
                            .frame(width: 72, height: 72)
                            .background(.black.opacity(0.5))
                            .foregroundStyle(.white)
                            .colorMultiply(.white)
                            .grayscale(1.0)
                            .font(.system(size: fontSize))
                            .fontWeight( isBold ? .bold : .regular)
                            .clipShape(RoundedRectangle(cornerSize: CGSizeMake(10, 10)))
                            .containerRelativeFrame(.horizontal)
                            .tag(WidgetTypes.accessoryCircular)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(maxWidth: .infinity)
                    .frame(height: deviceType == .pad ? 400 : 300)
                    .onChange(of: widgetStyleSelectedInPreview) { oldValue, newValue in
                        print(newValue.rawValue)
                        loadSettings(forWidgetNo: widgetNumber, widgetSize: widgetStyleSelectedInPreview)
                    }
                    .onAppear {
                        loadSettings(forWidgetNo: widgetNumber, widgetSize: widgetStyleSelectedInPreview)
                    }
                    .animation(.easeInOut(duration: 4), value: widgetStyleSelectedInPreview)
                }.onTapGesture {
                    self.hideKeyboard()
                }
                
                VStack {
                    TextEditor(text: $textfielContent)
                        .padding(15)
                        .scrollContentBackground(.hidden)
                        .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
                        .frame(height: 150)
                    VStack {
                        if deviceType == .pad {
                            Slider(value: $fontSize, in: 10...80, step: 1)
                        } else {
                            Slider(value: $fontSize, in: 5...30, step: 1)
                        }
                        Spacer()
                            .frame(height: 20)
                            .onTapGesture {
                                self.hideKeyboard()
                            }
                        Toggle(isOn: $isBold, label: {
                            Text("Should be bold")
                        })
                        .onTapGesture {
                            self.hideKeyboard()
                        }
                        ColorPicker("Background color", selection: $backgroundColor)
                    }
                    .padding([.leading, .trailing], 20)
                }
                .frame(maxWidth: 600)
            }
            .padding()
            .padding([.top], 30)
            .onAppear {
                
            }
            .onChange(of: textfielContent) {
                updateSettings(forWidgetNo: widgetNumber, widgetSize: widgetStyleSelectedInPreview)
            }
            .onChange(of: isBold) {
                updateSettings(forWidgetNo: widgetNumber, widgetSize: widgetStyleSelectedInPreview)
            }
            .onChange(of: backgroundColor) {
                updateSettings(forWidgetNo: widgetNumber, widgetSize: widgetStyleSelectedInPreview)
            }
            .onChange(of: fontSize) {
                updateSettings(forWidgetNo: widgetNumber, widgetSize: widgetStyleSelectedInPreview)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onReceive(iCloudChangePublisher, perform: { _ in
                loadSettings(forWidgetNo: widgetNumber, widgetSize: widgetStyleSelectedInPreview)
                WidgetCenter.shared.reloadAllTimelines()
            })
            Spacer()
        }
        .onOpenURL { url in
            if let widgetFamily = url.host(), let selectedWidget = WidgetTypes.init(rawValue: widgetFamily) {
                self.widgetStyleSelectedInPreview = selectedWidget
            }
        }
    }
    
    func updateSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
        sharedDefaults?.set(textfielContent, forKey: "\(forWidgetNo)-widgetContent")
        sharedDefaults?.set(fontSize, forKey: "\(forWidgetNo)-\(widgetSize)-widgetFontSize")
        sharedDefaults?.set(backgroundColor.rawValue, forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor")
        sharedDefaults?.set(isBold, forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold")
        
        icloudDefaults.set(textfielContent, forKey: "\(forWidgetNo)-widgetContent")
        icloudDefaults.set(backgroundColor.rawValue, forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor")
        icloudDefaults.set(isBold, forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold")
        
        icloudDefaults.synchronize()
    }
    
    func transferOldSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
        
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
        let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
        
        if let smallWidgetSize = sharedDefaults?.dictionary(forKey: "smallWidgetSize") as? [String: CGFloat] {
            self.smallWidgetSize.width = smallWidgetSize["width"] ?? 170
            self.smallWidgetSize.height = smallWidgetSize["height"] ?? 170
        }
        
        if let mediumWidgetSize = sharedDefaults?.dictionary(forKey: "mediumWidgetSize") as? [String: CGFloat] {
            self.mediumWidgetSize.width = mediumWidgetSize["width"] ?? 364
            self.mediumWidgetSize.height = mediumWidgetSize["height"] ?? 170
        }
        
        if let largeWidgetSize = sharedDefaults?.dictionary(forKey: "largeWidgetSize") as? [String: CGFloat] {
            self.largeWidgetSize.width = largeWidgetSize["width"] ?? 364
            self.largeWidgetSize.height = largeWidgetSize["height"] ?? 364
        }
        
        transferOldSettings(forWidgetNo: forWidgetNo, widgetSize: widgetSize)
        
        let textData = sharedDefaults?.object(forKey: "\(forWidgetNo)-widgetContent") as? String
        let fontSize = sharedDefaults?.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetFontSize") as? CGFloat
        let shouldBeBold = sharedDefaults?.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold") as? Bool
        let colorData = sharedDefaults?.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor") as? String
        
        let textDataFromiCloud = icloudDefaults.object(forKey: "\(forWidgetNo)-widgetContent") as? String
        let isBoldFromiCloud = icloudDefaults.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold") as? Bool
        let colorDataFromiCloud = icloudDefaults.object(forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor") as? String
        
        // This updates local data based on iCloud data
        if let textDataFromiCloud {
            sharedDefaults?.set(textDataFromiCloud, forKey: "\(forWidgetNo)-widgetContent")
        }
        
        if let isBoldFromiCloud {
            sharedDefaults?.set(isBoldFromiCloud, forKey: "\(forWidgetNo)-\(widgetSize)-widgetBold")
        }
        
        if let colorDataFromiCloud {
            sharedDefaults?.set(colorDataFromiCloud, forKey: "\(forWidgetNo)-\(widgetSize)-widgetColor")
        }
                
        if let colorDataFromiCloud {
            if let color = Color(rawValue: colorDataFromiCloud) {
                self.backgroundColor = color
            }
        } else if let colorData {
            if let color = Color(rawValue: colorData) {
                self.backgroundColor = color
            }
        } else {
            self.backgroundColor = Color(uiColor: UIColor(hue: CGFloat.random(in: 0.0...1.0), saturation: CGFloat.random(in: 0.0...1.0), brightness: CGFloat.random(in: 0.0...1.0), alpha: 1.0))
        }
        
        
        
        self.isBold = isBoldFromiCloud ?? shouldBeBold ?? false
        self.textfielContent = textDataFromiCloud ?? textData ?? "This is a preview text that will be in the widget"
        if let textData, textData.isEmpty {
            self.textfielContent = "This is a preview text that will be in the widget"
        }
        
        withAnimation {
            self.fontSize = fontSize ?? 15.0
        }
    }
}

#Preview {
    ContentView(textfielContent: "Preview Text")
}
