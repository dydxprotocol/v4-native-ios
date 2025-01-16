//
//  dydxSimpleUIMarketPositionView.swift
//  dydxUI
//
//  Created by Rui Huang on 26/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketPositionViewModel: PlatformViewModel {
    @Published public var closeAction: (() -> Void)?
    @Published public var shareAction: (() -> Void)?
    @Published public var unrealizedPNLAmount: SignedAmountViewModel?
    @Published public var entryPrice: String?
    @Published public var side: SideTextViewModel?
    @Published public var size: String?
    @Published public var amount: String?
    @Published public var logoUrl: URL?
    @Published public var funding: SignedAmountViewModel?
    @Published public var liquidationPrice: String?
    @Published public var symbol: String?

    @Published public var takeProfitStatusViewModel: dydxTakeProfitStopLossStatusViewModel?
    @Published public var stopLossStatusViewModel: dydxTakeProfitStopLossStatusViewModel?
    @Published public var takeProfitStopLossAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketPositionViewModel {
        let vm = dydxSimpleUIMarketPositionViewModel()
        vm.closeAction = {}
        vm.unrealizedPNLAmount = .previewValue
        vm.side = .previewValue
        vm.entryPrice = "$120.00"
        vm.size = "0.0012"
        vm.amount = "$120.00"
        vm.logoUrl = URL(string: "https://media.dydx.exchange/currencies/eth.png")
        vm.funding = .previewValue
        vm.liquidationPrice = "$120.00"
        vm.symbol = "USD"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self, self.side != nil else { return AnyView(PlatformView.nilView) }

            return AnyView(
                self.createContent(style: style)
                    .sectionHeader {
                        self.createHeader(style: style)
                    }
            )
        }
    }

    private func createContent(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                let amountHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SIZE"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: symbol ?? "-")
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: amountHeader.wrappedViewModel,
                                                        value: size)
                .frame(minWidth: 0, maxWidth: .infinity)

                let sizeHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SIZE"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD")
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: sizeHeader.wrappedViewModel,
                                                        value: amount)
                .frame(minWidth: 0, maxWidth: .infinity)

                let profitHeader = HStack {
                    Text(DataLocalizer.localize(path: "APP.SHARE_ACTIVITY_MODAL.PROFIT"))
                        .themeFont(fontType: .plus, fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    TokenTextViewModel(symbol: "USD")
                        .createView(parentStyle: style.themeFont(fontSize: .smallest))
                }
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        titleViewModel: profitHeader.wrappedViewModel,
                                                        valueViewModel: unrealizedPNLAmount)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)

            HStack {
                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        title: DataLocalizer.localize(path: "APP.GENERAL.FUNDING_RATE_CHART_SHORT"),
                                                        valueViewModel: funding)
                .frame(minWidth: 0, maxWidth: .infinity)

                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        title: DataLocalizer.localize(path: "APP.GENERAL.AVG_ENTRY"),
                                                        value: entryPrice)
                .frame(minWidth: 0, maxWidth: .infinity)

                CollectionItemUtil.createCollectionItem(parentStyle: style,
                                                        title: DataLocalizer.localize(path: "APP.TRADE.LIQUIDATION_PRICE_SHORT"),
                                                        value: liquidationPrice)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)

            self.createTpSlButtons(parentStyle: style)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    private func createHeader(style: ThemeStyle) -> some View {
        VStack {
            HStack(alignment: .center) {
                Text(DataLocalizer.localize(path: "APP.GENERAL.POSITION"))
                    .themeFont(fontType: .plus, fontSize: .large)
                    .themeColor(foreground: .textPrimary)
                    .padding(.leading, 16)

                DividerModel().createView(parentStyle: style)

                self.side?.createView(parentStyle: style.themeFont(fontSize: .small))

                Spacer()

                let content = Text(DataLocalizer.localize(path: "APP.TRADE.CLOSE_POSITION"))
                    .themeColor(foreground: .colorRed)
                    .themeFont(fontSize: .small)
                    .wrappedViewModel

                PlatformButtonViewModel(content: content, type: .pill, state: .secondary, action: { [weak self] in
                    self?.closeAction?()
                })
                    .createView(parentStyle: style)
            }
            .padding(.trailing, 16)

            Spacer(minLength: 24)
        }
    }

    private func createTpSlButtons(parentStyle: ThemeStyle) -> some View {
        var addTakeProfitStopLossButton: AnyView?

        if let takeProfitStopLossAction = self.takeProfitStopLossAction {
            let content = AnyView(
                HStack {
                    Spacer()
                    Text(DataLocalizer.localize(path: "APP.TRADE.ADD_TP_SL"))
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textSecondary)
                    Spacer()
                }
            )

            addTakeProfitStopLossButton = PlatformButtonViewModel(content: content.wrappedViewModel, state: .secondary) {
                takeProfitStopLossAction()
            }
            .createView(parentStyle: parentStyle)
            .wrappedInAnyView()
        }

        return VStack(spacing: 10) {
            if takeProfitStatusViewModel != nil || stopLossStatusViewModel != nil {
                HStack(spacing: 10) {
                    Group {
                        takeProfitStatusViewModel?.createView(parentStyle: parentStyle)
                            .frame(maxWidth: .infinity)
                        stopLossStatusViewModel?.createView(parentStyle: parentStyle)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxHeight: .infinity)
                }
            } else {
                addTakeProfitStopLossButton
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketPositionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketPositionViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketPositionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketPositionViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
