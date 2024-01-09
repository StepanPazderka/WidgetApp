//
//  MainView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 08.01.2024.
//

import SwiftUI
import Algorithms

struct MainView: View {
    @ObservedObject var widgetContentProvider = WidgetContentProvider()
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @State var selectedTab = 0
    
    @State var dragUpAmount = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $selectedTab) {
                ForEach(widgetContentProvider.widgetSettings.uniqued { $0.id }) { item in
                    WidgetSettingsView(widgetNumber: Int(item.id) ?? 0)
                        .tag(Int(item.id) ?? 0)
                        .frame(width: geometry.size.width * 0.95)
                        .frame(height: geometry.size.height * 0.95)
                        .background(Color(hue: 0.0, saturation: 0.0, brightness: 1.0))
                        .clipShape(.rect(cornerRadius: 45.0))
                        .padding(.horizontal, 100)
                        .shadow(radius: 10)
                        .offset(y: dragUpAmount.height)
                        .animation(.easeOut, value: selectedTab)
//                        .highPriorityGesture(
//                            DragGesture()
//                                .onChanged { gesture in
//                                    if gesture.translation.height < 0 {
//                                        self.dragUpAmount = gesture.translation
//                                    }
//                                }
//                                .onEnded { _ in
//                                    if self.dragUpAmount.height < -100 {
//                                        // dragUpAmount deletion logic here
//                                        print(dragUpAmount.height)
//                                        self.dragUpAmount.height = -100
//                                        // For example: items.remove(at: index)
//                                    }
//                                    self.dragUpAmount = .zero
//                                }
//                        )
                }
                .padding(.bottom, 10)
                Button {
                    widgetContentProvider.createNewWidgetSettings(forWidgetNo: widgetContentProvider.widgetSettings.count + 1)
                    selectedTab = widgetContentProvider.widgetSettings.endIndex
                } label: {
                    VStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text("Create new Widget")
                    }
                }
            }
            .containerRelativeFrame(.horizontal)
            .edgesIgnoringSafeArea(.all)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .padding(.bottom, horizontalSizeClass == .regular ? 0 : 2)
        }
        .background(Color(hue: 0.0, saturation: 0.0, brightness: 0.9))
    }
}

#Preview {
    MainView()
}
