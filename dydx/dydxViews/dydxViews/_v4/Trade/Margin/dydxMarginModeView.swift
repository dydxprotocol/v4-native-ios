//
//  dydxMarginModeView.swift
//  dydxUI
//
//  Created by Rui Huang on 07/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarginModeItemViewModel: PlatformViewModel {
    @Published public var title: String?
    @Published public var detail: String?
    @Published public var isDisabled: Bool = false
    @Published public var isSelected: Bool = false
    @Published public var selectedAction: (() -> Void)?

    private let cornerRadius: CGFloat = 8

    public init(title: String? = nil, detail: String? = nil, isSelected: Bool = false, selectedAction: (() -> Void)? = nil) {
        self.title = title
        self.detail = detail
        self.isSelected = isSelected
        self.selectedAction = selectedAction
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let buttonContent = VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(self.title ?? "")
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: self.isDisabled ? .textTertiary : .textPrimary)

                    Spacer()

                    if !self.isDisabled {
                        if self.isSelected {
                            self.createSelectedCheckmark(parentStyle: style)
                        } else {
                            self.createUnselectedCheckmark(parentStyle: style)
                        }
                    }
                }

                Text(self.detail ?? "")
                    .multilineTextAlignment(.leading)
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
            }
                .padding(16)
                .leftAligned()
                .themeColor(background: self.isSelected ? ThemeColor.SemanticColor.layer1 : ThemeColor.SemanticColor.layer3)
                .borderAndClip(style: .cornerRadius(8),
                               borderColor: isSelected ? .colorPurple : isDisabled ? .textTertiary : .layer7,
                               lineWidth: isSelected ? 2 : 1)
                .wrappedViewModel

            return AnyView(
                PlatformButtonViewModel(content: buttonContent,
                                        type: PlatformButtonType.iconType,
                                        action: self.selectedAction ?? {})
                    .createView(parentStyle: style)
                    .disabled(isDisabled)
            )
        }
    }

    private func createSelectedCheckmark(parentStyle: ThemeStyle) -> some View {
        PlatformIconViewModel(type: .asset(name: "icon_checked", bundle: Bundle.dydxView),
                             clip: .circle(background: .colorPurple,
                                           spacing: 12,
                                           borderColor: nil),
                             size: CGSize(width: 20, height: 20),
                             templateColor: .textPrimary)
       .createView(parentStyle: parentStyle)
    }

    private func createUnselectedCheckmark(parentStyle: ThemeStyle) -> some View {
        Circle()
            .fill(ThemeColor.SemanticColor.layer1.color)
            .frame(width: 20, height: 20)
            .overlay(
                Circle().stroke(ThemeColor.SemanticColor.layer5.color, lineWidth: 1)
            )
    }
}

public class dydxMarginModeViewModel: PlatformViewModel {
    @Published public var market: String?
    @Published public var items: [dydxMarginModeItemViewModel] = []

    public init() { }

    public static var previewValue: dydxMarginModeViewModel {
        let vm = dydxMarginModeViewModel()
        vm.market = "ETH-USD"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.MARGIN_MODE"))
                        .themeColor(foreground: .textPrimary)

                    Text(self.market ?? "")
                        .themeColor(foreground: .textSecondary)

                    Spacer()
                }
                .themeFont(fontType: .plus, fontSize: .largest)
                .padding(.top, 40)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(self.items, id: \.id) { item in
                        item.createView(parentStyle: style)
                    }
                }

                InlineAlertViewModel(.init(title: nil, body: DataLocalizer.localize(path: "WARNINGS.TRADE_BOX.UNABLE_TO_CHANGE_MARGIN_MODE", params: ["MARKET": self.market ?? "--"]), level: .warning))
                    .createView()
                Spacer()
            }
                .padding(.horizontal)
                .themeColor(background: .layer3)
                .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxMarginModeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarginModeViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarginModeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarginModeViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
