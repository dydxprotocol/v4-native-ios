//
//  BuyingPowerTooltip.swift
//  dydxUI
//
//  Created by Rui Huang on 24/04/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class BuyingPowerTooltipModel: PlatformViewModel {
    @Published public var learnMoreAction: (() -> Void)?

    @Published private var presented: Bool = false
    private lazy var presentedBindng = Binding(
        get: { [weak self] in self?.presented == true },
        set: { [weak self] in self?.presented = $0 }
    )

    public init() { }

    public static var previewValue: BuyingPowerTooltipModel {
        let vm = BuyingPowerTooltipModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else {
                return AnyView(PlatformView.nilView)
            }

            let attributedTitle = AttributedString(DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER"))
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
            let label = Text(attributedTitle.dottedUnderline(foreground: .textTertiary))
                .themeColor(foreground: .textTertiary)
                .wrappedViewModel
            let content = VStack(alignment: .leading, spacing: 8) {
                Text(DataLocalizer.localize(path: "APP.SIMPLE_UI.BUYING_POWER_TOOLTIP"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                Text(DataLocalizer.localize(path: "APP.GENERAL.LEARN_MORE"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: ThemeColor.SemanticColor.colorPurple)
                    .onTapGesture { [weak self] in
                        self?.presented = false
                        self?.learnMoreAction?()
                    }
            }

            let view = label.createView(parentStyle: style)
                .onTapGesture { [weak self] in
                    self?.presented.toggle()
                }
                .popover(present: presentedBindng, attributes: {
                    $0.position = .absolute(
                          originAnchor: .top,
                          popoverAnchor: .bottom
                      )
                    $0.sourceFrameInset = .init(top: 0, left: 0, bottom: -16, right: 0)
                    $0.presentation.animation = .none
                    $0.blocksBackgroundTouches = true
                    $0.onTapOutside = { [weak self] in
                        self?.presented = false
                    }
                }, view: {
                    content
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .cornerRadius(8), borderColor: .layer6, lineWidth: 1)
                    .environmentObject(ThemeSettings.shared)
                })

            return AnyView(view)
        }
    }
}

#if DEBUG
struct BuyingPowerTooltip_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return BuyingPowerTooltipModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct BuyingPowerTooltip_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return BuyingPowerTooltipModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
