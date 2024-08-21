//
//  dydxMarketAccountView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/13/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketAccountViewModel: PlatformViewModel {
    @Published public var sharedAccountViewModel: SharedAccountViewModel? = SharedAccountViewModel()

    public init() { }

    public static var previewValue: dydxMarketAccountViewModel {
        let vm = dydxMarketAccountViewModel()
        vm.sharedAccountViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack {
                    GeometryReader { container in
                        VStack(spacing: 0) {
                            DividerModel().createView(parentStyle: style)

                            HStack(alignment: .top, spacing: 8) {
                                self.createCellView(title: DataLocalizer.localize(path: "APP.GENERAL.BUYING_POWER"),
                                               value: Text(self.sharedAccountViewModel?.buyingPower ?? "-"))
                                .padding(8)

                                DividerModel().createView(parentStyle: style)
                                    .padding(.top, 6)

                                let value = HStack {
                                    Text(self.sharedAccountViewModel?.marginUsage ?? "-")
                                    self.sharedAccountViewModel?.marginUsageIcon?.createView(parentStyle: style)
                                }
                                self.createCellView(title: DataLocalizer.localize(path: "APP.GENERAL.MARGIN_USAGE"),
                                                    value: value)
                                .padding(.vertical, 8)
                             }
                            .frame(height: container.size.height / 3)

                            DividerModel().createView(parentStyle: style)

                            HStack(alignment: .top, spacing: 8) {
                                self.createCellView(title: DataLocalizer.localize(path: "APP.GENERAL.EQUITY"),
                                               value: Text(self.sharedAccountViewModel?.equity ?? "-"))
                                .padding(8)

                                DividerModel().createView(parentStyle: style)

                                self.createCellView(title: DataLocalizer.localize(path: "APP.GENERAL.FREE_COLLATERAL"),
                                               value: Text(self.sharedAccountViewModel?.freeCollateral ?? "-"))
                                .padding(.vertical, 8)
                            }
                            .frame(height: container.size.height / 3)

                            DividerModel().createView(parentStyle: style)

                            HStack(alignment: .top) {
                                self.createCellView(title: DataLocalizer.localize(path: "APP.TRADE.OPEN_INTEREST"),
                                               value: Text(self.sharedAccountViewModel?.openInterest ?? "-"))
                                .padding(8)

                                DividerModel().createView(parentStyle: style)
                                    .padding(.bottom, -6)

                                let value = HStack {
                                    Text(self.sharedAccountViewModel?.leverage ?? "-")
                                    self.sharedAccountViewModel?.leverageIcon?.createView(parentStyle: style)
                                }
                                self.createCellView(title: DataLocalizer.localize(path: "APP.GENERAL.LEVERAGE"),
                                               value: value)
                                .padding(.vertical, 8)
                            }
                            .frame(height: container.size.height / 3)

                            DividerModel().createView(parentStyle: style)
                        }
                    }
                    .padding(.vertical, 24)
                }
            )
        }
    }

    private func createCellView<Content: View>(title: String, value: Content) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(title)
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .small)

            value
        }
        .leftAligned()
        .padding(8)
    }
}

#if DEBUG
struct dydxMarketAccountView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAccountViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketAccountView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAccountViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
