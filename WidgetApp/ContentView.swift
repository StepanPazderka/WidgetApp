//
//  ContentView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI

struct ContentView: View {
    @State var textfielContent = ""
    
    var body: some View {
        TextField("Enter widget content", text: $textfielContent)
            .padding()
            .padding([.top], 30)
            .padding([.leading, .trailing], 20)
        Spacer()
            .onChange(of: textfielContent) {
                let sharedDefaults = UserDefaults(suiteName: "group.com.pazderka.widgetApp")
                sharedDefaults?.set(textfielContent, forKey: "widgetContent")
                
                let readData = sharedDefaults?.object(forKey: "widgetContent")
                print(readData)
            }
    }
}

#Preview {
    ContentView()
}
