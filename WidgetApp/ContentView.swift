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
    @State var textfielContent = ""
    @State var backgroundColor = Color(.sRGB, red: 1.0, green: 1.0, blue: 1.0)
    @State var fontSize: CGFloat = 15.0
    @State var isBold = false
    
    var body: some View {
        VStack {
            Group {
                WidgetView(text: $textfielContent, fontSize: $fontSize)
                    .padding(10)
                    .background(backgroundColor)
                    .border(.black)
                    .fontWeight(isBold ? .bold : .medium)
            }
            .background(.black)
            .frame(maxWidth: .infinity)
            TextField("Enter widget content", text: $textfielContent)
                .frame(height: 200)
                .colorInvert()
            Toggle(isOn: $isBold, label: {
                Text("Should be bold")
            })
            ColorPicker("Background color", selection: $backgroundColor)
            Slider(value: $fontSize, in: 15...50)
        }
        .padding()
        .padding([.top], 30)
        .padding([.leading, .trailing], 20)
        .onAppear {
            let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
            let readData = sharedDefaults?.object(forKey: "widgetContent") as? String
            let fontSize = sharedDefaults?.object(forKey: "widgetFontSize") as? CGFloat
            let colorData = sharedDefaults?.object(forKey: "widgetColor") as? String
            var color: Color?
            if let colorData {
                if let color = Color(rawValue: colorData) {
                    self.backgroundColor = color
                }
            }
            
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
        sharedDefaults?.set(backgroundColor.rawValue, forKey: "widgetColor")
    }
}

#Preview {
    ContentView(textfielContent: "Preview Text")
}
