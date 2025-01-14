//
//  dydxSimpleUIPortfolioPeriodView.swift
//  dydxUI
//
//  Created by Rui Huang on 13/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIPortfolioPeriodViewModel: PlatformViewModel {
    public struct OptionItem: Hashable, Equatable {
        public init(text: String, value: String) {
            self.text = text
            self.value = value
        }

        public let text: String
        public let value: String

        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(value)
        }

        public static func == (lhs: OptionItem, rhs: OptionItem) -> Bool {
            lhs.text == rhs.text &&
            lhs.value == rhs.value
        }
    }

    @Published public var items: [OptionItem] = []
    @Published public var selectedIndex: Int = 0
    @Published public var selectAction: ((Int) -> Void)?

    @Published private var present: Bool = false
    private lazy var presentBinding = Binding(
        get: { [weak self] in
            self?.present ?? false
        },
        set: { [weak self] in
            self?.present = $0
        }
    )

    public init() { }

    public static var previewValue: dydxSimpleUIPortfolioPeriodViewModel {
        let vm = dydxSimpleUIPortfolioPeriodViewModel()
        vm.items = [
            .init(text: "Day", value: "day"),
            .init(text: "Week", value: "week"),
            .init(text: "Month", value: "month"),
            .init(text: "Year", value: "year")
        ]
        vm.selectedIndex = 0
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Button(action: { [weak self] in
                    if !(self?.present ?? false) {
                        self?.present = true
                    }
                 }, label: {
                     let selectedIndex = self.selectedIndex
                     if selectedIndex < self.items.count {
                         Text(self.items[selectedIndex].text)
                             .themeFont(fontSize: .smaller)
                             .themeColor(foreground: .textPrimary)
                             .padding(.horizontal, 8)
                             .padding(.vertical, 4)
                             .themeColor(background: .layer5)
                             .cornerRadius(7, corners: .allCorners)
                     }
                })
                .popover(present: self.presentBinding, attributes: { attrs in
                    attrs.position = .absolute(
                               originAnchor: .bottom,
                               popoverAnchor: .topLeft
                           )

                    attrs.sourceFrameInset.top = -8
                    let animation = Animation.easeOut(duration: 0.2)
                    attrs.presentation.animation = animation
                    attrs.dismissal.animation = animation
                    attrs.rubberBandingMode = .none
                    attrs.blocksBackgroundTouches = true
                    attrs.onTapOutside = {
                        self.present = false
                    }
                }, view: {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(self.items.enumerated()), id: \.element) { index, item in
                            Button(action: {
                                if index != self.selectedIndex {
                                    self.selectedIndex = index
                                    self.selectAction?(index)
                                }
                                self.present = false
                            }) {
                                HStack {
                                    Text(item.text)
                                        .themeFont(fontSize: .medium)
                                        .themeColor(foreground: .textPrimary)
                                    Spacer()
                                    if index == self.selectedIndex {
                                        PlatformIconViewModel(type: .system(name: "checkmark"), size: CGSize(width: 16, height: 16))
                                            .createView(parentStyle: parentStyle, styleKey: styleKey)
                                    }
                                }
                                .contentShape(Rectangle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }

                            if index != self.items.count - 1 {
                                DividerModel().createView(parentStyle: style)
                            }
                        }
                    }
                    .frame(width: 160)
                    .fixedSize()
                    .themeColor(background: .layer3)
                    .cornerRadius(16, corners: .allCorners)
                    .border(cornerRadius: 16)
                    .environmentObject(ThemeSettings.shared)
                }, background: {
                    ThemeColor.SemanticColor.layer0.color.opacity(0.7)
                })
            )
        }
    }
}

#if DEBUG
struct dydxSimpleUIPortfolioPeriodView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIPortfolioPeriodViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIPortfolioPeriodView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIPortfolioPeriodViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
