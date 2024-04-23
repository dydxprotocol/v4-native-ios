//
//  dydxMarketPositionView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketPositionViewModel: PlatformViewModel {
    @Published public var takeProfitStopLossAction: (() -> Void)?
    @Published public var closeAction: (() -> Void)?
    @Published public var unrealizedPNLAmount: SignedAmountViewModel?
    @Published public var unrealizedPNLPercent: String?
    @Published public var realizedPNLAmount: SignedAmountViewModel?
    @Published public var leverage: String?
    @Published public var leverageIcon: LeverageRiskModel?
    @Published public var liquidationPrice: String?
    @Published public var side: SideTextViewModel?
    @Published public var size: String?
    @Published public var amount: String?
    @Published public var token: TokenTextViewModel?
    @Published public var logoUrl: URL?
    @Published public var gradientType: GradientType = .none

    @Published public var openPrice: String?
    @Published public var closePrice: String?
    @Published public var funding: SignedAmountViewModel?

    @Published public var takeProfitStatusViewModel: dydxTakeProftiStopLossStatusViewModel?
    @Published public var stopLossStatusViewModel: dydxTakeProftiStopLossStatusViewModel?

    public init() { }

    public static var previewValue: dydxMarketPositionViewModel {
        let vm = dydxMarketPositionViewModel()
        vm.closeAction = {}
        vm.unrealizedPNLAmount = .previewValue
        vm.unrealizedPNLPercent = "0.00%"
        vm.realizedPNLAmount = .previewValue
        vm.leverage = "$12.00"
        vm.leverageIcon = .previewValue
        vm.liquidationPrice = "$12.00"
        vm.side = .previewValue
        vm.size = "0.0012"
        vm.amount = "$120.00"
        vm.token = .previewValue
        vm.logoUrl = URL(string: "https://media.dydx.exchange/currencies/eth.png")
        vm.gradientType = .plus
        vm.openPrice = "$12.00"
        vm.closePrice = "$12.00"
        vm.funding = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack {
                    self.createCollection(parentStyle: style)

                    self.createButtons(parentStyle: style)

                    self.createList(parentStyle: style)
                }
                .themeColor(background: .layer2)
                .frame(width: UIScreen.main.bounds.width - 16)
            )
        }
    }

    private func createCollection(parentStyle: ThemeStyle) -> some View {
        VStack(spacing: 0) {
            HStack {
                createPositionTab(parentStyle: parentStyle)

                VStack(alignment: .leading, spacing: 16) {
                    let value = HStack {
                        Text(leverage ?? "-")
                        leverageIcon?.createView(parentStyle: parentStyle)
                    }
                    self.createCollectionItem(parentStyle: parentStyle, title: DataLocalizer.localize(path: "APP.GENERAL.LEVERAGE"), valueViewModel: value.wrappedViewModel)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 58)

                    DividerModel().createView(parentStyle: parentStyle)

                    self.createCollectionItem(parentStyle: parentStyle, title: DataLocalizer.localize(path: "APP.TRADE.LIQUIDATION_PRICE"), stringValue: liquidationPrice)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 58)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.vertical, 8)

            DividerModel().createView(parentStyle: parentStyle)
                .padding(.top, 8)

            HStack(alignment: .top, spacing: 0) {
                let unrealizedValue = VStack(alignment: .leading) {
                    unrealizedPNLAmount?
                        .createView(parentStyle: parentStyle.themeFont(fontSize: .large))

                    Text(unrealizedPNLPercent ?? "")
                        .themeFont(fontType: .number, fontSize: .smaller)
                        .themeColor(foreground: .textTertiary)
                }.wrappedViewModel

                let realizedValue = VStack(alignment: .leading) {
                    realizedPNLAmount?
                        .createView(parentStyle: parentStyle.themeFont(fontSize: .large))
                    Spacer()
                }.wrappedViewModel

                self.createCollectionItem(parentStyle: parentStyle, title: DataLocalizer.localize(path: "APP.TRADE.UNREALIZED_PNL"), valueViewModel: unrealizedValue)
                    .padding(.vertical, 16)
                    .frame(height: 96)

                DividerModel().createView(parentStyle: parentStyle)
                    .frame(height: 82)

                self.createCollectionItem(parentStyle: parentStyle, title: DataLocalizer.localize(path: "APP.TRADE.REALIZED_PNL"), valueViewModel: realizedValue)
                    .padding(.vertical, 16)
                    .frame(height: 96)
            }
        }
    }

    private func createPositionTab(parentStyle: ThemeStyle) -> some View {
        Group {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    PlatformIconViewModel(type: .url(url: logoUrl),
                                          clip: .defaultCircle,
                                          size: CGSize(width: 32, height: 32))
                        .createView(parentStyle: parentStyle)

                    Spacer()

                    side?.createView(parentStyle: parentStyle.themeFont(fontSize: .small))
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(size ?? "")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        token?.createView(parentStyle: parentStyle.themeFont(fontSize: .smallest))
                    }
                    Text(amount ?? "")
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .small)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .padding(20)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 152)
        .themeGradient(background: .layer3, gradientType: gradientType)
        .cornerRadius(16)
    }

    private func createCollectionItem(parentStyle: ThemeStyle, title: String?, stringValue: String?) -> some View {
        VStack(alignment: .leading) {
            Text(title ?? "")
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .leftAligned()
            Spacer()
            Text(stringValue ?? "-")
                .leftAligned()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(.horizontal, 8)
    }

    private func createCollectionItem(parentStyle: ThemeStyle, title: String?, valueViewModel: PlatformViewModel?) -> some View {
        VStack(alignment: .leading) {
            Text(title ?? "")
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .leftAligned()
            Spacer()
            valueViewModel?.createView(parentStyle: parentStyle, styleKey: nil)
                .leftAligned()
        }
        .padding(.horizontal, 8)
    }

    private func createButtons(parentStyle: ThemeStyle) -> some View {
        var closePositionButton: AnyView?
        var addTakeProfitStopLossButton: AnyView?

        if let closeAction = self.closeAction {
            let content = HStack {
                Spacer()
                Text(DataLocalizer.localize(path: "APP.TRADE.CLOSE_POSITION"))
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: ThemeSettings.negativeColor)
                Spacer()
            }

            closePositionButton = PlatformButtonViewModel(content: content.wrappedViewModel, state: .secondary) {
                closeAction()
            }
            .createView(parentStyle: parentStyle)
            .wrappedInAnyView()
        }

        if let takeProfitStopLossAction = self.takeProfitStopLossAction {
            let content = AnyView(
                HStack {
                    Spacer()
                    Text(DataLocalizer.localize(path: "APP.TRADE.ADD_TP_SL"))
                        .themeFont(fontSize: .medium)
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
            if takeProfitStatusViewModel?.triggerPrice ?? stopLossStatusViewModel?.triggerPrice != nil {
                HStack(spacing: 10) {
                    takeProfitStatusViewModel?.createView(parentStyle: parentStyle)
                    stopLossStatusViewModel?.createView(parentStyle: parentStyle)
                }
                closePositionButton
            } else {
                HStack(spacing: 10) {
                    addTakeProfitStopLossButton
                    closePositionButton
                }
            }
        }
        .padding(.bottom, 16)
    }

    private func createList(parentStyle: ThemeStyle) -> some View {
        VStack {
            HStack {
                Text(DataLocalizer.localize(path: "APP.TRADE.AVERAGE_OPEN"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)

                Spacer()

                Text(openPrice ?? "-")
                    .themeFont(fontSize: .medium)
            }

            DividerModel().createView(parentStyle: parentStyle)

            HStack {
                Text(DataLocalizer.localize(path: "APP.TRADE.AVERAGE_CLOSE"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)

                Spacer()

                Text(closePrice ?? "-")
                    .themeFont(fontSize: .medium)
            }

            DividerModel().createView(parentStyle: parentStyle)

            HStack {
                Text(DataLocalizer.localize(path: "APP.TRADE.NET_FUNDING"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)

                Spacer()

                funding?.createView(parentStyle: parentStyle.themeFont(fontSize: .medium))
            }
        }
        .padding(.horizontal, 8)
    }
}

#if DEBUG
struct dydxMarketPositionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPositionViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketPositionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPositionViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
