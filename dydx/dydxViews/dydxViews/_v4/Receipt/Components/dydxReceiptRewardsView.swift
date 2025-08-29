//
//  dydxReceiptRewardsView.swift
//  dydxUI
//
//  Created by Rui Huang on 9/22/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxReceiptRewardsViewModel: PlatformViewModel {
    @Published public var rewards: SignedAmountViewModel?
    @Published public var nativeTokenLogoUrl: URL?

    @Published public var isSep2025: Bool = false
    @Published public var rewardsSep2025: SignedAmountViewModel?

    @Published private var presented: Bool = false
    private lazy var presentedBindng = Binding(
        get: { [weak self] in self?.presented == true },
        set: { [weak self] in self?.presented = $0 }
    )

    public init() { }

    public static var previewValue: dydxReceiptRewardsViewModel {
        let vm = dydxReceiptRewardsViewModel()
        vm.rewards = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            if self.isSep2025 {
                let attributedTitle = AttributedString(DataLocalizer.localize(path: "APP.GENERAL.EST_REWARDS"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                let label = Text(attributedTitle.dottedUnderline(foreground: .textTertiary))
                    .themeColor(foreground: .textTertiary)
                    .wrappedViewModel
                let content = VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "TRADE.MAXIMUM_REWARDS.BODY",
                                                params: ["REWARD_AMOUNT": "1M"]))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }
                let labelView = label.createView(parentStyle: style)
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

                return AnyView(
                    HStack(spacing: 4) {
                        labelView

                        Spacer()

                        if let rewards = self.rewardsSep2025 {
                            rewards.createView(parentStyle: style
                                .themeFont(fontType: .number, fontSize: .small)
                                .themeColor(foreground: .textPrimary))
                            .lineLimit(1)
                        } else {
                            dydxReceiptEmptyView.emptyValue
                        }

                    }
                )
            } else {
                return AnyView(
                    HStack(spacing: 4) {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.EST_REWARDS"))
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textTertiary)
                            .lineLimit(1)
                        if let nativeTokenLogoUrl = self.nativeTokenLogoUrl {
                            PlatformIconViewModel(type: .url(url: nativeTokenLogoUrl),
                                                  size: CGSize(width: 18, height: 18))
                            .createView(parentStyle: style)
                        }

                        Spacer()

                        if let rewards = self.rewards {
                            rewards.createView(parentStyle: style
                                .themeFont(fontType: .number, fontSize: .small)
                                .themeColor(foreground: .textPrimary))
                            .lineLimit(1)
                        } else {
                            dydxReceiptEmptyView.emptyValue
                        }
                    }
                )
            }
        }
    }
}

#if DEBUG
struct dydxReceiptRewardsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptRewardsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxReceiptRewardsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptRewardsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
