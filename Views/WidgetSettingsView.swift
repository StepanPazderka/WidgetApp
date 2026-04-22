//
//  ContentView.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 21.12.2023.
//

import SwiftUI
import WidgetKit
import UIKit

struct WidgetSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
	
	@EnvironmentObject private var widgetSettingsRepository: WidgetSettingsRepository
    
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
				.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
				.frame(maxWidth: .infinity)
				.frame(height: deviceType == .pad ? 400 : 300)
					.onChange(of: selectedWidgetFamily) { oldValue, newValue in
						loadSettings(forWidgetNo: selectedWidgetID, widgetSize: newValue)
					}
				.onAppear {
					loadSettings(forWidgetNo: selectedWidgetID, widgetSize: selectedWidgetFamily)
				}
				.animation(.easeInOut(duration: 4), value: selectedWidgetFamily)
			}.onTapGesture {
				self.hideKeyboard()
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
			.frame(maxWidth: 600)
		}
		.padding()
		.padding([.top], 30)
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
    
    func updateSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
		widgetSettingsRepository.updateWidgetSettings(
			id: forWidgetNo,
			widgetFamily: widgetSize,
			text: widgetText,
			color: widgetBackgroundColor,
			isBold: widgetIsBold,
			fontSize: widgetFontSize
		)
    }
    
    func loadSettings(forWidgetNo: Int, widgetSize: WidgetTypes) {
		guard let settings = widgetSettingsRepository.widgetSettings(for: forWidgetNo, widgetFamily: widgetSize) else {
			widgetBackgroundColor = .primary
			widgetIsBold = false
			widgetText = "This is a preview text that will be in the widget"
			widgetFontSize = 20.0
			return
		}
		
		widgetBackgroundColor = settings.color
		widgetIsBold = settings.shouldBeBold
		widgetText = settings.text.isEmpty ? "This is a preview text that will be in the widget" : settings.text
		
		withAnimation {
			widgetFontSize = settings.fontSize
		}
    }
}

#Preview {
	WidgetSettingsView(widgetText: "Preview Text", selectedWidgetID: 0)
}
