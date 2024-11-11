//
//  dydxPortfolioChartView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/4/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioChartViewModel: PlatformViewModel {
    @Published public var state: dydxPortfolioViewModel.State = .onboard
    @Published public var chart: dydxChartViewModel?

    @Published public var resolutionTitles: [String]?
    @Published public var onResolutionChanged: ((Int) -> Void)?
    @Published public var resolutionIndex: Int? = 0

    @Published public var equity: String?
    @Published public var pnl: SignedAmountViewModel?

    @Published public var equityLabel: String?
    @Published public var pnlLabel: String?

    public init() { }

    public static var previewValue: dydxPortfolioChartViewModel {
        let vm = dydxPortfolioChartViewModel()
        vm.chart = .previewValue
        vm.resolutionTitles = ["1d", "7d", "30d", "90d"]
        vm.equity = "$2,300.00"
        vm.pnl = .previewValue
        vm.equity = "Portfolio Value"
        vm.pnlLabel = "P&L"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Group {
                    VStack(spacing: 0) {
                        self.createInfoView(parentStyle: style)

                        self.chart?.createView(parentStyle: style)
                            .frame(height: 174)

                        self.createResolutionControl(parentStyle: style)
                    }
                    .frame(height: 290)
                    .frame(maxWidth: .infinity)
                    .themeColor(background: .layer3)
                    .cornerRadius(28)
                }
                .cornerRadius(28, corners: [.topLeft, .topRight])
            )
        }
    }

    private func createInfoView(parentStyle: ThemeStyle) -> some View {
        Group {
            if let equity = equity {
                VStack {
                    HStack {
                        Text(equityLabel ?? "")
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .small)

                        Spacer()

                        Text(pnlLabel ?? "")
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .small)

                    }

                    HStack {
                        Text(equity)
                            .themeFont(fontSize: .larger)
                            .themeColor(foreground: .textPrimary)

                        Spacer()

                        pnl?.createView(parentStyle: parentStyle.themeFont(fontSize: .medium))
                    }
                }
             } else {
                Text("")
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
        .frame(height: 60)
    }

    private func createResolutionControl(parentStyle: ThemeStyle) -> some View {
        let items = self.resolutionTitles?.compactMap {
            Text($0)
                .themeFont(fontType: .plus, fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .padding(8)
                .wrappedViewModel
        }
        let selectedItems = self.resolutionTitles?.compactMap {
            Text($0)
                .themeFont(fontType: .plus, fontSize: .small)
                .themeColor(foreground: .textPrimary)
                .padding(8)
                .cornerRadius(8)
                .wrappedViewModel
        }
        return AnyView(
            TabGroupModel(items: items,
                          selectedItems: selectedItems,
                          currentSelection: self.resolutionIndex,
                          onSelectionChanged: self.onResolutionChanged,
                          spacing: 24)
                .createView(parentStyle: parentStyle)
                .padding(.bottom, 16)
        )
    }
}

#if DEBUG
struct dydxPortfolioChartView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioChartViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioChartView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioChartViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
