//
//  dydxPortfolioPositionsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxPortfolioPositionItemViewModel: PlatformViewModel {
    public struct Handler: Hashable {
        public static func == (lhs: dydxPortfolioPositionItemViewModel.Handler, rhs: dydxPortfolioPositionItemViewModel.Handler) -> Bool {
            true
        }

        public func hash(into hasher: inout Hasher) { }

        public var onTapAction: (() -> Void)?
        public var onCloseAction: (() -> Void)?
        public var onMarginEditAction: (() -> Void)?
    }

    public init(size: String? = nil,
                notionalValue: String? = nil,
                token: TokenTextViewModel? = TokenTextViewModel(),
                sideText: SideTextViewModel = SideTextViewModel(),
                leverage: String? = nil,
                leverageIcon: LeverageRiskModel? = nil,
                liquidationPrice: String? = nil,
                indexPrice: String? = nil,
                entryPrice: String? = nil,
                unrealizedPnl: SignedAmountViewModel? = nil,
                unrealizedPnlPercent: SignedAmountViewModel? = nil,
                logoUrl: URL? = nil,
                gradientType: GradientType = .none,
                onTapAction: (() -> Void)? = nil,
                onMarginEditAction: (() -> Void)? = nil) {
        self.size = size
        self.notionalValue = notionalValue
        self.token = token
        self.sideText = sideText
        self.leverage = leverage
        self.leverageIcon = leverageIcon
        self.liquidationPrice = liquidationPrice
        self.indexPrice = indexPrice
        self.unrealizedPnlPercent = "10%"
        self.gradientType = gradientType
        self.logoUrl = logoUrl
        self.handler = Handler(onTapAction: onTapAction, onMarginEditAction: onMarginEditAction)
    }

    @Published public var size: String?
    @Published public var notionalValue: String?
    @Published public var token: TokenTextViewModel?
    @Published public var sideText = SideTextViewModel()
    @Published public var leverage: String?
    @Published public var leverageIcon: LeverageRiskModel?
    @Published public var liquidationPrice: String?
    @Published public var entryPrice: String?
    @Published public var indexPrice: String?
    @Published public var unrealizedPnl: SignedAmountViewModel?
    @Published public var unrealizedPnlPercent: String = ""
    @Published public var marginValue: String = "--"
    @Published public var marginMode: String = "--"
    @Published public var isMarginAdjustable: Bool = false
    @Published public var logoUrl: URL?
    @Published public var gradientType: GradientType
    @Published public var handler: Handler?

    public static var previewValue: dydxPortfolioPositionItemViewModel {
        let item = dydxPortfolioPositionItemViewModel(
            size: "299",
            notionalValue: "$420.69",
            token: .previewValue,
            sideText: .previewValue,
            leverage: "0.01x",
            indexPrice: "$1,200",
            entryPrice: "$1,200",
            unrealizedPnl: .previewValue,
            unrealizedPnlPercent: .previewValue,
            logoUrl: URL(string: "https://media.dydx.exchange/currencies/eth.png"),
            gradientType: .plus)
        return item
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let rightCellSwipeAccessoryView = PlatformIconViewModel(type: .asset(name: "action_cancel", bundle: Bundle.dydxView), size: .init(width: 16, height: 16))
                .createView(parentStyle: style, styleKey: styleKey)
                .tint(ThemeColor.SemanticColor.layer2.color)

            let rightCellSwipeAccessory = CellSwipeAccessory(accessoryView: AnyView(rightCellSwipeAccessoryView)) {
                self.handler?.onCloseAction?()
            }

            return AnyView(
                VStack(spacing: 20) {
                    self.createTopView(parentStyle: style)
                    self.createBottomView(parentStyle: style)
                }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .themeGradient(background: .layer3, gradientType: self.gradientType)
                    .cornerRadius(16)
                    .onTapGesture { [weak self] in
                        self?.handler?.onTapAction?()
                    }
//                    .swipeActions(leftCellSwipeAccessory: nil, rightCellSwipeAccessory: rightCellSwipeAccessory)
            )
        }
    }

    private func createTopView(parentStyle: ThemeStyle) -> some View {
        HStack(spacing: 0) {
            createLogo(parentStyle: parentStyle)
            Spacer(minLength: 8)
            createTopRowStats(parentStyle: parentStyle)
        }
    }

    private func createBottomView(parentStyle: ThemeStyle) -> some View {
        SingleAxisGeometryReader(axis: .horizontal, alignment: .center) { width in
            let numElements: CGFloat = 3.0
            let spacing: CGFloat = 8
            let elementWidth = max(0, (width - (numElements - 1) * spacing) / numElements)
            return HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.LIQ_ORACLE"))
                            .themeFont(fontSize: .smaller)
                            .themeColor(foreground: .textTertiary)

                        Text(self.liquidationPrice ?? "")
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textPrimary)

                        Text(self.indexPrice ?? "")
                            .themeFont(fontSize: .smaller)
                            .themeColor(foreground: .textTertiary)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: elementWidth, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.PROFIT_AND_LOSS"))
                            .themeFont(fontSize: .smaller)
                            .themeColor(foreground: .textTertiary)

                        self.unrealizedPnl?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .small))
                        Text(self.unrealizedPnlPercent)
                            .themeFont(fontSize: .smaller)
                            .themeColor(foreground: .textTertiary)
                    }
                    .frame(width: elementWidth, alignment: .leading)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.MARGIN"))
                            .themeFont(fontSize: .smaller)
                            .themeColor(foreground: .textTertiary)

                        HStack(spacing: 8) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(self.marginValue)
                                    .themeFont(fontSize: .small)
                                    .themeColor(foreground: .textPrimary)

                                Text(self.marginMode)
                                    .themeFont(fontSize: .smaller)
                                    .themeColor(foreground: .textTertiary)
                            }

                            if self.isMarginAdjustable {

                                let buttonContent = PlatformIconViewModel(type: .asset(name: "icon_edit", bundle: Bundle.dydxView),
                                                                          size: CGSize(width: 20, height: 20),
                                                                          templateColor: .textSecondary)
                                PlatformButtonViewModel(content: buttonContent,
                                                        type: PlatformButtonType.iconType) { [weak self] in
                                    self?.handler?.onMarginEditAction?()
                                }
                                                        .createView(parentStyle: parentStyle)
                                                        .frame(width: 32, height: 32)
                                                        .themeColor(background: .layer6)
                                                        .border(borderWidth: 1, cornerRadius: 7, borderColor: ThemeColor.SemanticColor.layer7.color)
                            }
                        }
                    }
                    .frame(width: elementWidth, alignment: .leading)
                }
            }

        }
    }

    private func createLogo( parentStyle: ThemeStyle) -> some View {
        HStack {
            PlatformIconViewModel(type: .url(url: logoUrl),
                                  clip: .defaultCircle,
                                  size: CGSize(width: 32, height: 32))
            .createView(parentStyle: parentStyle)
        }
    }

    private func createTopRowStats(parentStyle: ThemeStyle) -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(size ?? "")
                        .themeFont(fontType: .base, fontSize: .small)
                        .themeColor(foreground: .textPrimary)
                    token?.createView(parentStyle: parentStyle.themeFont(fontSize: .smallest))
                }
                Text(notionalValue ?? "")
                    .themeFont(fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
            }

            Spacer(minLength: 8)
            HStack(alignment: .top, spacing: 2) {
                sideText
                    .createView(parentStyle: parentStyle.themeFont(fontSize: .smaller))
                Text("@")
                    .themeFont(fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)

                Text(leverage ?? "")
                    .themeFont(fontType: .base, fontSize: .smaller)
                    .themeColor(foreground: .textPrimary)
            }
        }
    }
}

public class dydxPortfolioPositionsViewModel: PlatformViewModel {
    @Published public var emptyText: String?
    @Published public var positionItems: [dydxPortfolioPositionItemViewModel] {
        didSet {
            contentChanged?()
        }
    }
    @Published public var pendingPositionItems: [dydxPortfolioPendingPositionsItemViewModel] {
        didSet {
            contentChanged?()
        }
    }
    @Published public var shouldDisplayVaultSection: Bool = false
    @Published public var vaultBalance: String?
    @Published public var vaultApy: Double?
    @Published public var vaultTapAction: (() -> Void)?

    public var contentChanged: (() -> Void)?

    init(
        positionItems: [dydxPortfolioPositionItemViewModel] = [],
        pendingPositionItems: [dydxPortfolioPendingPositionsItemViewModel] = [],
        vaultBalance: String? = nil,
        vaultApy: String? = nil,
        emptyText: String? = nil
    ) {
        self.positionItems = positionItems
        self.pendingPositionItems = pendingPositionItems
        self.emptyText = emptyText
    }

    public static var previewValue: dydxPortfolioPositionsViewModel {
        dydxPortfolioPositionsViewModel(
            positionItems: [
                .previewValue,
                .previewValue
            ],
            pendingPositionItems: [
                .previewValue
            ],
            vaultBalance: "324.320",
            emptyText: "empty")
    }

    public var pendingPositionsHeader: PlatformViewModel? {
        guard !pendingPositionItems.isEmpty else { return nil }
        return HStack(spacing: 8) {
            Text(localizerPathKey: "APP.TRADE.UNOPENED_ISOLATED_POSITIONS")
                .themeFont(fontSize: .larger)
                .themeColor(foreground: .textPrimary)
                .fixedSize()
            Text("\(pendingPositionItems.count)")
                .frame(width: 28, height: 28)
                .themeColor(background: .layer3)
                .themeColor(foreground: .textSecondary)
                .borderAndClip(style: .circle, borderColor: .borderDefault)
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width - 32)
        .themeFont(fontSize: .small)
        .themeColor(foreground: .textTertiary)
        .wrappedViewModel
    }

    private var openPositionsView: some View {
        LazyVStack {
            if let emptyText = self.emptyText, positionItems.isEmpty {
                AnyView(
                    PlaceholderViewModel(text: emptyText)
                        .createView()
                )
            } else {
                let items = self.positionItems.map { $0.createView() }
                ForEach(items.indices, id: \.self) { index in
                    items[index]
                }
            }
        }
    }

    @ViewBuilder
    private var pendingPositionsView: AnyView? {
        if !pendingPositionItems.isEmpty {
            let unopenedItems = self.pendingPositionItems.map { $0.createView() }
            LazyVStack {
                self.pendingPositionsHeader?.createView()

                ForEach(unopenedItems.indices, id: \.self) { index in
                    unopenedItems[index]
                }
            }
            .wrappedInAnyView()
        }
    }

    @ViewBuilder
    public var apyAccessory: some View {
        if let vaultApy, let vaultApyText = dydxFormatter.shared.percent(number: vaultApy, digits: 2) {
            Text(vaultApyText)
                .themeFont(fontSize: .medium)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .themeColor(foreground: vaultApy < 0 ? ThemeSettings.negativeColor : ThemeSettings.positiveColor)
                .themeColor(background: vaultApy < 0 ? ThemeSettings.negativeColorLayer : ThemeSettings.positiveColorLayer)
                .cornerRadius(8)
        }
    }

    @ViewBuilder
    public var megaVaultBalanceRow: some View {
        if let vaultBalance {
            HStack(spacing: 0) {
                PlatformIconViewModel(type: .asset(name: "icon_chain", bundle: .dydxView),
                                      clip: .noClip,
                                      size: .init(width: 32, height: 32),
                                      templateColor: nil)
                .createView()
                Color.clear.frame(width: 16)
                Text(localizerPathKey: "APP.VAULTS.YOUR_VAULT_BALANCE")
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)
                Spacer()
                Text(vaultBalance)
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textPrimary)
            }
            .padding(.all, 16)
            .themeColor(background: .layer3)
            .cornerRadius(16)
        }
    }

    @ViewBuilder
    public var megaVaultSection: some View {
        if dydxBoolFeatureFlag.isVaultEnabled.isEnabled && shouldDisplayVaultSection {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Text(localizerPathKey: "APP.VAULTS.MEGAVAULT")
                        .themeFont(fontType: .plus, fontSize: .larger)
                        .themeColor(foreground: .textPrimary)
                    apyAccessory
                }
                .leftAligned()
                megaVaultBalanceRow
                    .onTapGesture { [weak self] in
                        self?.vaultTapAction?()
                    }
            }

        }
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                ScrollView {
                    VStack(spacing: 24) {
                        self.openPositionsView
                        self.pendingPositionsView
                        self.megaVaultSection
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxPortfolioPositionsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioPositionsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioPositionsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioPositionsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
