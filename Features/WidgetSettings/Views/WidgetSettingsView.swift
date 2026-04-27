//
//  ContentView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
import WidgetKit
import UIKit
import SwiftData

struct WidgetSettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query private var storedSettings: [StoredWidgetSettings]

    @State private var widgetText = "This is a preview text that will be in the widget"
    @State private var widgetBackgroundColor: Color = .white
    @State private var widgetFontSize: CGFloat = 30.0
    @State private var widgetPadding: CGFloat = 10.0
    @State private var widgetIsBold = false
    @State private var isSyncingFromModel = false

    @State private var selectedWidgetFamily: WidgetTypes = .systemSmall
    @State var selectedWidgetID: Int

    @State private var smallWidgetSize = CGSize(width: 170, height: 170)
    @State private var mediumWidgetSize = CGSize(width: 364, height: 170)
    @State private var largeWidgetSize = CGSize(width: 364, height: 364)
    @State private var extraLargeWidgetSize = CGSize(width: 715, height: 364)

    private let defaultWidgetText = "This is a preview text that will be in the widget"
    private var deviceType: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    var body: some View {
        VStack {
            VStack {
                TabView(selection: $selectedWidgetFamily) {
                    WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
                        .padding(deviceType == .pad ? 4 : 7)
                        .frame(width: smallWidgetSize.width, height: smallWidgetSize.height)
                        .background(widgetBackgroundColor)
                        .foregroundStyle(widgetBackgroundColor.complementaryColor(for: widgetBackgroundColor))
                        .font(.system(size: widgetFontSize))
                        .fontWeight(widgetIsBold ? .bold : .regular)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
                        .containerRelativeFrame(.horizontal)
                        .tag(WidgetTypes.systemSmall)

                    WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
                        .padding(6)
                        .frame(width: mediumWidgetSize.width, height: mediumWidgetSize.height)
                        .background(widgetBackgroundColor)
                        .foregroundStyle(widgetBackgroundColor.complementaryColor(for: widgetBackgroundColor))
                        .font(.system(size: widgetFontSize))
                        .fontWeight(widgetIsBold ? .bold : .regular)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
                        .containerRelativeFrame(.horizontal)
                        .tag(WidgetTypes.systemMedium)

                    if deviceType == .pad {
                        WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
                            .padding(6)
                            .frame(width: largeWidgetSize.width, height: largeWidgetSize.height)
                            .background(widgetBackgroundColor)
                            .foregroundStyle(widgetBackgroundColor.complementaryColor(for: widgetBackgroundColor))
                            .font(.system(size: widgetFontSize))
                            .fontWeight(widgetIsBold ? .bold : .regular)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
                            .containerRelativeFrame(.horizontal)
                            .tag(WidgetTypes.systemLarge)

                        WidgetView(text: $widgetText, fontSize: $widgetFontSize, shouldBeBold: $widgetIsBold, textPadding: $widgetPadding)
                            .padding(6)
                            .frame(width: extraLargeWidgetSize.width, height: extraLargeWidgetSize.height)
                            .background(widgetBackgroundColor)
                            .foregroundStyle(widgetBackgroundColor.complementaryColor(for: widgetBackgroundColor))
                            .font(.system(size: widgetFontSize))
                            .fontWeight(widgetIsBold ? .bold : .regular)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
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
                        .fontWeight(widgetIsBold ? .bold : .regular)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
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
                        .fontWeight(widgetIsBold ? .bold : .regular)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                        .containerRelativeFrame(.horizontal)
                        .tag(WidgetTypes.accessoryCircular)
                }
                .onOpenURL { url in
                    if let widgetType = WidgetTypes(rawValue: url.pathComponents[1]) {
                        withAnimation {
                            selectedWidgetFamily = widgetType
                        }
                    }
                }
                .padding(0)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(maxWidth: .infinity)
                .frame(height: deviceType == .pad ? 400 : 300)
                .onChange(of: selectedWidgetFamily) { _, newValue in
                    loadSettings(forWidgetNo: selectedWidgetID, widgetSize: newValue)
                }
                .onAppear {
                    loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
                }
                .animation(.easeInOut(duration: 4), value: selectedWidgetFamily)
            }
            .onTapGesture {
                hideKeyboard()
            }

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
                            hideKeyboard()
                        }

                    Toggle(isOn: $widgetIsBold) {
                        Text("Should be bold")
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }

                    ColorPicker("Background color", selection: $widgetBackgroundColor)
                }
                .padding([.leading, .trailing], 20)
            }
            .frame(maxWidth: 600)
        }
        .padding()
        .padding([.top], 30)
        .onAppear {
            loadWidgetPreviewSizes()
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
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .padding(5)
        .padding([.bottom], 15)
        .padding([.top], 20)
        .shadow(radius: 10)
    }

    private func matchingStoredSettings(forWidgetNo: Int, widgetSize: WidgetTypes) -> StoredWidgetSettings? {
        storedSettings.first {
            $0.widgetId == forWidgetNo && $0.widgetTypeRawValue == widgetSize.rawValue
        }
    }

    private func fallbackStoredSettings(forWidgetNo: Int) -> StoredWidgetSettings? {
        storedSettings.first { $0.widgetId == forWidgetNo }
    }

    private func makeDefaultSettings(forWidgetNo: Int, widgetSize: WidgetTypes) -> StoredWidgetSettings {
        let settings = StoredWidgetSettings.makeDefault(withWidgetId: forWidgetNo)
        settings.widgetTypeRawValue = widgetSize.rawValue
        return settings
    }

    private func updateSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
        guard !isSyncingFromModel else { return }

        let settings = matchingStoredSettings(forWidgetNo: forWidgetNo, widgetSize: widgetSize) ?? {
            let newSettings = makeDefaultSettings(forWidgetNo: forWidgetNo, widgetSize: widgetSize)
            modelContext.insert(newSettings)
            return newSettings
        }()

        settings.text = widgetText
        settings.shouldBeBold = widgetIsBold
        settings.colorRawValue = widgetBackgroundColor.rawValue
        settings.fontSize = Double(widgetFontSize)

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Could not save widget settings: \(error.localizedDescription)")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private func loadSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
        isSyncingFromModel = true
        defer { isSyncingFromModel = false }

        let settings = matchingStoredSettings(forWidgetNo: forWidgetNo, widgetSize: widgetSize) ?? fallbackStoredSettings(forWidgetNo: forWidgetNo)

        guard let settings else {
            widgetBackgroundColor = .white
            widgetIsBold = false
            widgetText = defaultWidgetText
            widgetFontSize = 15.0
            return
        }

        withAnimation(.easeInOut(duration: 2)) {
            widgetBackgroundColor = Color(rawValue: settings.colorRawValue) ?? .white
        }
        widgetIsBold = settings.shouldBeBold
        widgetText = settings.text.isEmpty ? defaultWidgetText : settings.text

        withAnimation {
            widgetFontSize = CGFloat(settings.fontSize)
        }
    }

    private func loadWidgetPreviewSizes() {
        guard let sharedDefaults = UserDefaults(suiteName: bundleID) else { return }

        if let storedSize = sharedDefaults.dictionary(forKey: "smallWidgetSize") {
            smallWidgetSize = size(from: storedSize, fallback: smallWidgetSize)
        }

        if let storedSize = sharedDefaults.dictionary(forKey: "mediumWidgetSize") {
            mediumWidgetSize = size(from: storedSize, fallback: mediumWidgetSize)
        }

        if let storedSize = sharedDefaults.dictionary(forKey: "largeWidgetSize") {
            largeWidgetSize = size(from: storedSize, fallback: largeWidgetSize)
        }

        if let storedSize = sharedDefaults.dictionary(forKey: "extraLargeWidgetSize") {
            extraLargeWidgetSize = size(from: storedSize, fallback: extraLargeWidgetSize)
        }
    }

    private func size(from dictionary: [String: Any], fallback: CGSize) -> CGSize {
        let width = (dictionary["width"] as? NSNumber)?.doubleValue ?? Double(fallback.width)
        let height = (dictionary["height"] as? NSNumber)?.doubleValue ?? Double(fallback.height)
        return CGSize(width: width, height: height)
    }
}

#Preview {
    WidgetSettingsView(selectedWidgetID: 0)
}
