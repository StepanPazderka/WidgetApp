//
//  WidgetView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI

struct WidgetView: View {
    @Binding var text: String
    @Binding var fontSize: CGFloat
    @Binding var shouldBeBold: Bool
    @Binding var textPadding: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .padding(textPadding)
    }
}

#Preview {
    WidgetView(text: .constant("Widget test content"), fontSize: .constant(20), shouldBeBold: .constant(true), textPadding: .constant(0))
}
