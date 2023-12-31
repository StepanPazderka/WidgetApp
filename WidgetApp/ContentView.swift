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
    @Environment(\.colorScheme) var colorScheme
    
    @State var textfielContent = ""
    @State var backgroundColor = Color(.sRGB, red: 1.0, green: 1.0, blue: 1.0)
    @State var fontSize: CGFloat = 30.0
    @State var padding: CGFloat = 10.0
    @State var isBold = false
    
    var body: some View {
        VStack {
            VStack {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        HStack(alignment: .center) {
                            WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold, textPadding: $padding)
                                .padding(17)
                                .frame(width: 180, height: 180)
                                .background(backgroundColor)
                                .foregroundStyle(backgroundColor.complementaryColor(for: backgroundColor))
                                .font(.system(size: fontSize))
                                .fontWeight( isBold ? .bold : .regular)
                                .clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
                                .containerRelativeFrame(.horizontal)
                            WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold, textPadding: $padding)
                                .padding(17)
                                .frame(width: 350, height: 180)
                                .background(backgroundColor)
                                .foregroundStyle(backgroundColor.complementaryColor(for: backgroundColor))
                                .font(.system(size: fontSize))
                                .fontWeight( isBold ? .bold : .regular)
                                .clipShape(RoundedRectangle(cornerSize: CGSizeMake(30, 30)))
                                .containerRelativeFrame(.horizontal)
                        }
                    }
                    .scrollTargetLayout()
                }
                .padding(0)
                .scrollTargetBehavior(.paging)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
            }
            
            Spacer()
            TextEditor(text: $textfielContent)
                .padding(15)
                .scrollContentBackground(.hidden)
                .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
                .frame(height: 150)
            Spacer()
                .frame(height: 50)
            VStack {
                Slider(value: $fontSize, in: 10...30, step: 1)
                Spacer()
                Toggle(isOn: $isBold, label: {
                    Text("Should be bold")
                })
                ColorPicker("Background color", selection: $backgroundColor)
            }
            .padding([.leading, .trailing], 20)
            Spacer()
                .frame(height: 150)
        }
        .padding()
        .padding([.top], 30)
        .onAppear {
            let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
            let readData = sharedDefaults?.object(forKey: "widgetContent") as? String
            let fontSize = sharedDefaults?.object(forKey: "widgetFontSize") as? CGFloat
            let shouldBeBold = sharedDefaults?.object(forKey: "widgetBold") as? Bool
            
            let colorData = sharedDefaults?.object(forKey: "widgetColor") as? String
            var color: Color?
            if let colorData {
                if let color = Color(rawValue: colorData) {
                    self.backgroundColor = color
                }
            }
            
            self.isBold = shouldBeBold ?? false
            self.textfielContent = readData ?? ""
            self.fontSize = fontSize ?? 15.0
        }
        .onChange(of: textfielContent) {
            updateSettings()
        }
        .onChange(of: isBold) {
            updateSettings()
        }
        .onChange(of: backgroundColor) {
            updateSettings()
        }
        .onChange(of: fontSize) {
            updateSettings()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
        Spacer()
    }
    
    func updateSettings() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
        sharedDefaults?.set(textfielContent, forKey: "widgetContent")
        sharedDefaults?.set(fontSize, forKey: "widgetFontSize")
        print("Saving font size \(fontSize)")
        sharedDefaults?.set(backgroundColor.rawValue, forKey: "widgetColor")
        sharedDefaults?.set(isBold, forKey: "widgetBold")
    }
}

#Preview {
    ContentView(textfielContent: "Preview Text")
}
