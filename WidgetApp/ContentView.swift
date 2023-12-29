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
    @State var isBold = false
    
    var body: some View {
        VStack {
            WidgetView(text: $textfielContent, fontSize: $fontSize, shouldBeBold: $isBold)
                .frame(width: 200, height: 200)
                .padding(20)
                .background(backgroundColor)
                .fontWeight(isBold ? .bold : .regular)
                .foregroundStyle(backgroundColor.complementaryColor(for: backgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .frame(maxWidth: .infinity)
            Spacer()
                .frame(height: 50)
            TextField("Enter widget content", text: $textfielContent)
                .frame(height: 40)
                .padding(20)
                .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 30.0, style: .continuous))
            Spacer()
                .frame(height: 50)
            VStack {
                Toggle(isOn: $isBold, label: {
                    Text("Should be bold")
                })
                ColorPicker("Background color", selection: $backgroundColor)
            }
            .padding([.leading, .trailing], 20)
            Spacer()
//            Slider(value: $fontSize, in: 10...30)
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
            //            updateSettings()
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
        sharedDefaults?.set(backgroundColor.rawValue, forKey: "widgetColor")
        sharedDefaults?.set(isBold, forKey: "widgetBold")
    }
}

#Preview {
    ContentView(textfielContent: "Preview Text")
}
