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

    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
    }
}

#Preview {
    WidgetView(text: .constant("Just some text"), fontSize: .constant(20), shouldBeBold: .constant(true))
}
