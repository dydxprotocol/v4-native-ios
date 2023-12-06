//
//  dydxPortfolioDetailsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/4/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioDetailsViewModel: PlatformViewModel {
    @Published public var expanded: Bool = false
    @Published public var expandAction: (() -> Void)?
    @Published public var sharedAccountViewModel: SharedAccountViewModel? = SharedAccountViewModel()

    public init() { }

    public static var previewValue: dydxPortfolioDetailsViewModel {
        let vm = dydxPortfolioDetailsViewModel()
        vm.sharedAccountViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(spacing: 0) {
                    Spacer()

                    self.createDetails(parentStyle: style)
                        .padding(.horizontal, 16)
                    Button(action: self.expandAction ?? {}) {
                        HStack {
                            Spacer()
                            let iconName = self.expanded ? "dragger_close" : "dragger_open"
                            PlatformIconViewModel(type: .asset(name: iconName, bundle: Bundle.dydxView),
                                                             size: CGSize(width: 44, height: 44))
                                .createView(parentStyle: parentStyle)
                            Spacer()
                        }
                        .frame(height: 44)
                        .contentShape(Rectangle())
                    }
                }
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer5)
                .cornerRadius(28)
            )
        }
    }

    private func createDetails(parentStyle: ThemeStyle) -> some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.FREE_COLLATERAL"))
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .small)

                    Text(sharedAccountViewModel?.freeCollateral ?? "-")
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.MARGIN_USAGE"))
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .small)

                    HStack {
                        sharedAccountViewModel?.marginUsageIcon?.createView(parentStyle: parentStyle)
                        Text(sharedAccountViewModel?.marginUsage ?? "-")
                    }
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER"))
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .small)

                    Text(sharedAccountViewModel?.buyingPower ?? "-")
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.LEVERAGE"))
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .small)

                    HStack {
                        sharedAccountViewModel?.leverageIcon?.createView(parentStyle: parentStyle)
                        Text(sharedAccountViewModel?.leverage ?? "-")
                    }
                }
            }
        }
    }
}

#if DEBUG
struct dydxPortfolioDetailsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioDetailsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioDetailsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioDetailsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
