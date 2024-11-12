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
    @Published public var emptyText: String?

    @Published public var takeProfitStopLossAction: (() -> Void)?
    @Published public var closeAction: (() -> Void)?
    @Published public var editMarginAction: (() -> Void)?
    @Published public var unrealizedPNLAmount: SignedAmountViewModel?
    @Published public var unrealizedPNLPercent: String = ""
    @Published public var realizedPNLAmount: SignedAmountViewModel?
    @Published public var marginMode: String?
    @Published public var margin: String?
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

    @Published public var takeProfitStatusViewModel: dydxTakeProfitStopLossStatusViewModel?
    @Published public var stopLossStatusViewModel: dydxTakeProfitStopLossStatusViewModel?

    @Published public var pendingPosition: dydxPortfolioPendingPositionsItemViewModel? {
        didSet {
            contentChanged?()
        }
    }

    @Published public var contentChanged: (() -> Void)?

    public init() { }

    public static var previewValue: dydxMarketPositionViewModel {
        let vm = dydxMarketPositionViewModel()
        vm.closeAction = {}
        vm.unrealizedPNLAmount = .previewValue
        vm.unrealizedPNLPercent = "10%"
        vm.realizedPNLAmount = .previewValue
        vm.marginMode = "Cross"
        vm.margin = "$10"
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
                VStack(spacing: 24) {
                    // check size to determine if there is current position data to display
                    VStack {
                        if let emptyText = self.emptyText {
                            PlaceholderViewModel(text: emptyText)
                                .createView()
                        } else {
                            self.createCollection(parentStyle: style)
                            self.createButtons(parentStyle: style)
                            self.createList(parentStyle: style)
                        }
                    }

                    if let pendingPosition = self.pendingPosition {
                        VStack(spacing: 16) {
                            self.createPendingPositionsHeader(parentStyle: style)
                            pendingPosition.createView(parentStyle: style)
                        }
                    }
                }
                .themeColor(background: .layer2)
                .frame(width: UIScreen.main.bounds.width - 32)
            )
        }
    }

    private var unrealizedView: AnyView {
        VStack(alignment: .leading, spacing: 6) {
            Text(DataLocalizer.localize(path: "APP.TRADE.UNREALIZED_PNL"))
                .themeFont(fontType: .plus, fontSize: .small)
                .themeColor(foreground: .textTertiary)
            VStack(alignment: .leading, spacing: 2) {
                self.unrealizedPNLAmount?
                    .createView(parentStyle: .defaultStyle.themeFont(fontSize: .large))
                Text(self.unrealizedPNLPercent)
                    .themeFont(fontSize: .smaller)
                    .themeColor(foreground: .textSecondary)
            }
        }
        .wrappedInAnyView()
    }

    private var realizedView: AnyView {
        VStack(alignment: .leading, spacing: 6) {
            Text(DataLocalizer.localize(path: "APP.TRADE.REALIZED_PNL"))
                .themeFont(fontType: .plus, fontSize: .small)
                .themeColor(foreground: .textTertiary)
            realizedPNLAmount?
                .createView(parentStyle: .defaultStyle.themeFont(fontSize: .large))
        }
        .wrappedInAnyView()
    }

    private var marginView: AnyView? {
        guard let marginMode = marginMode, let margin = margin else { return nil }
        return VStack(alignment: .leading, spacing: 6) {
            Text(DataLocalizer.localize(path: "APP.GENERAL.MARGIN_WITH_MODE", params: ["MODE": marginMode]))
                .themeFont(fontType: .plus, fontSize: .small)
                .themeColor(foreground: .textTertiary)
            Text(margin)
                .themeFont(fontSize: .medium)
                .themeColor(foreground: .textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Spacer(minLength: 0)
        }
        .wrappedInAnyView()
    }

    private var statsRow: some View {
        let views = [unrealizedView, realizedView, marginView].compactMap { $0 }
        return Group {
            // left aligned
            if views.count == 2 {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(views.indices, id: \.self) { index in
                        views[index]
                            .padding(.vertical, 8)
                        if index < views.count - 1 {
                            DividerModel().createView()
                        }
                    }
                    Spacer()
                }
            } else {
                // even spacing
                HStack(alignment: .top, spacing: 0) {
                    ForEach(views.indices, id: \.self) { index in
                        Spacer()
                        views[index]
                            .padding(.vertical, 8)
                        Spacer()
                        if index < views.count - 1 {
                            DividerModel().createView()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .wrappedInAnyView()
    }

    private func createCollection(parentStyle: ThemeStyle) -> some View {
        VStack(spacing: 12) {
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

            statsRow
        }
        .padding(.bottom, 8)

    }

    private func createPositionTab(parentStyle: ThemeStyle) -> some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    PlatformIconViewModel(type: .url(url: logoUrl),
                                          clip: .defaultCircle,
                                          size: CGSize(width: 36, height: 36))
                        .createView(parentStyle: parentStyle)

                    Spacer(minLength: 4)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(size ?? "")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text(amount ?? "")
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }

                Spacer()

                HStack(spacing: 0) {
                    side?.createView(parentStyle: parentStyle.themeFont(fontSize: .small))
                    Spacer(minLength: 4)
                    if let marginMode = marginMode {
                        Text(marginMode)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textSecondary)
                            .themeColor(background: .layer7)
                            .clipShape(.rect(cornerRadius: 4))
                    }
                }
            }
            .padding(16)
        }
        .frame(width: 162, height: 142)
        .themeGradient(background: .layer3, gradientType: gradientType)
        .cornerRadius(12)
    }

    private func createCollectionItem(parentStyle: ThemeStyle, title: String?, stringValue: String?) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title ?? "")
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                    .fixedSize(horizontal: true, vertical: false)
                    .leftAligned()
                Text(stringValue ?? "-")
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            Spacer()
        }
        .padding(.horizontal, 8)
    }

    private func createCollectionItem(parentStyle: ThemeStyle, title: String?, valueViewModel: PlatformViewModel?) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title ?? "")
                    .themeFont(fontType: .plus, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                    .fixedSize(horizontal: true, vertical: false)
                    .leftAligned()
                valueViewModel?.createView(parentStyle: parentStyle, styleKey: nil)
                    .fixedSize(horizontal: true, vertical: false)
                    .leftAligned()
            }
            Spacer()
        }

        .padding(.horizontal, 8)
    }

    private func createButtons(parentStyle: ThemeStyle) -> some View {
        var closePositionButton: AnyView?
        var addTakeProfitStopLossButton: AnyView?
        var editMarginButton: AnyView?

        if let closeAction = self.closeAction {
            let content = HStack {
                Spacer()
                Text(DataLocalizer.localize(path: "APP.TRADE.CLOSE_POSITION"))
                    .themeFont(fontType: .plus, fontSize: .medium)
                    .themeColor(foreground: ThemeSettings.negativeColor)
                Spacer()
            }

            closePositionButton = PlatformButtonViewModel(content: content.wrappedViewModel, state: .destructive) {
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

        if let editMarginAction = self.editMarginAction {
            let content = AnyView(
                HStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 8) {
                        PlatformIconViewModel(type: .asset(name: "icon_edit", bundle: Bundle.dydxView),
                                              size: CGSize(width: 20, height: 20),
                                              templateColor: .textSecondary)
                        .createView()
                        Text(DataLocalizer.localize(path: "APP.TRADE.EDIT_MARGIN"))
                            .themeFont(fontSize: .medium)
                            .themeColor(foreground: .textSecondary)
                    }
                    Spacer()
                }
            )

            editMarginButton = PlatformButtonViewModel(content: content.wrappedViewModel, state: .secondary) {
                editMarginAction()
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
                HStack(spacing: 10) {
                    closePositionButton
                    editMarginButton
                }
            } else {
                HStack(spacing: 10) {
                    addTakeProfitStopLossButton
                        .frame(maxWidth: .infinity)
                    editMarginButton
                        .frame(maxWidth: .infinity)
                }
                closePositionButton
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
                    .themeColor(foreground: .textSecondary)
            }

            DividerModel().createView(parentStyle: parentStyle)

            HStack {
                Text(DataLocalizer.localize(path: "APP.TRADE.AVERAGE_CLOSE"))
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)

                Spacer()

                Text(closePrice ?? "-")
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)
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

    private func createPendingPositionsHeader(parentStyle: ThemeStyle) -> some View {
        Text(localizerPathKey: "APP.TRADE.UNOPENED_ISOLATED_POSITIONS")
            .themeFont(fontSize: .larger)
            .themeColor(foreground: .textSecondary)
            .leftAligned()
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
