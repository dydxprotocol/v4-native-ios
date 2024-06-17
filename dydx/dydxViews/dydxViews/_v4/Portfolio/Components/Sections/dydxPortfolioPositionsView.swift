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
                token: TokenTextViewModel? = TokenTextViewModel(),
                sideText: SideTextViewModel = SideTextViewModel(),
                leverage: String? = nil,
                leverageIcon: LeverageRiskModel? = nil,
                indexPrice: String? = nil,
                entryPrice: String? = nil,
                unrealizedPnl: SignedAmountViewModel? = nil,
                unrealizedPnlPercent: SignedAmountViewModel? = nil,
                logoUrl: URL? = nil,
                gradientType: GradientType = .none,
                onTapAction: (() -> Void)? = nil,
                onMarginEditAction: (() -> Void)? = nil) {
        self.size = size
        self.token = token
        self.sideText = sideText
        self.leverage = leverage
        self.leverageIcon = leverageIcon
        self.indexPrice = indexPrice
        self.entryPrice = entryPrice
        self.unrealizedPnlPercent = unrealizedPnlPercent
        self.gradientType = gradientType
        self.logoUrl = logoUrl
        self.handler = Handler(onTapAction: onTapAction, onMarginEditAction: onMarginEditAction)
    }

    public var size: String?
    public var token: TokenTextViewModel?
    public var sideText = SideTextViewModel()
    public var leverage: String?
    public var leverageIcon: LeverageRiskModel?
    public var indexPrice: String?
    public var entryPrice: String?
    public var unrealizedPnl: SignedAmountViewModel?
    public var unrealizedPnlPercent: SignedAmountViewModel?
    public var marginValue: String = "--"
    public var marginMode: String = "--"
    public var isMarginAdjustable: Bool = false
    public var logoUrl: URL?
    public var gradientType: GradientType
    public var handler: Handler?

    public static var previewValue: dydxPortfolioPositionItemViewModel {
        let item = dydxPortfolioPositionItemViewModel(
            size: "299",
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
                VStack {
                    self.createTopView(parentStyle: style)
                    self.createBottomView(parentStyle: style)
                }
                    .frame(height: 120)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .themeGradient(background: .layer3, gradientType: self.gradientType)
                    .cornerRadius(16)
                    .onTapGesture { [weak self] in
                        self?.handler?.onTapAction?()
                    }
                    .swipeActions(leftCellSwipeAccessory: nil, rightCellSwipeAccessory: rightCellSwipeAccessory)
            )
        }
    }

    private func createTopView(parentStyle: ThemeStyle) -> some View {
        let icon = self.createLogo(parentStyle: parentStyle)
        let main = self.createMain(parentStyle: parentStyle)

        return PlatformTableViewCellViewModel(logo: icon.wrappedViewModel,
                                              main: main.wrappedViewModel)
        .createView(parentStyle: parentStyle)
    }

    private func createBottomView(parentStyle: ThemeStyle) -> some View {
        GeometryReader { geo in
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.INDEX_ENTRY"))
                        .themeFont(fontSize: .smaller)
                        .themeColor(foreground: .textTertiary)

                    Text(self.indexPrice ?? "")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textPrimary)
                        .minimumScaleFactor(0.5)

                    Text(self.entryPrice ?? "")
                        .themeFont(fontSize: .smaller)
                        .themeColor(foreground: .textTertiary)
                        .minimumScaleFactor(0.5)
                }
                .leftAligned()
                .frame(width: geo.size.width / 3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.PROFIT_AND_LOSS"))
                        .themeFont(fontSize: .smaller)
                        .themeColor(foreground: .textTertiary)

                    self.unrealizedPnlPercent?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .small))

                    self.unrealizedPnl?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .smaller).themeColor(foreground: .textTertiary))
                }
                .leftAligned()
                .frame(width: geo.size.width / 3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.MARGIN"))
                        .themeFont(fontSize: .smaller)
                        .themeColor(foreground: .textTertiary)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(self.marginValue)
                                .themeFont(fontSize: .small)
                                .themeColor(foreground: .textPrimary)
                                .minimumScaleFactor(0.5)

                            Text(self.marginMode)
                                .themeFont(fontSize: .smaller)
                                .themeColor(foreground: .textTertiary)
                                .minimumScaleFactor(0.5)
                        }

                        Spacer()

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
                .leftAligned()
                .frame(width: geo.size.width / 3)
            }
        }
        .padding(.horizontal, 16)
    }

    private func createLogo( parentStyle: ThemeStyle) -> some View {
        HStack {
            PlatformIconViewModel(type: .url(url: logoUrl),
                                  clip: .defaultCircle,
                                  size: CGSize(width: 32, height: 32))
            .createView(parentStyle: parentStyle)
        }
    }

    private func createMain(parentStyle: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 2) {
                Text(size ?? "")
                    .themeFont(fontType: .number, fontSize: .small)

                token?.createView(parentStyle: parentStyle.themeFont(fontSize: .smallest))
            }

            HStack(spacing: 2) {
                sideText
                    .createView(parentStyle: parentStyle.themeFont(fontSize: .smaller))
                Text("@")
                    .themeFont(fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)

                Text(leverage ?? "")
                    .themeFont(fontType: .number, fontSize: .smaller)
            }
        }
        .leftAligned()
        .minimumScaleFactor(0.5)
    }

    private func createTrailing(parentStyle: ThemeStyle) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                unrealizedPnl?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .small))

                unrealizedPnlPercent?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .smaller))
            }
        }
        .frame(maxWidth: 80)
    }
}

public class dydxPortfolioPositionsViewModel: PlatformViewModel {
    // TODO: remove once isolated markets is supported and force released
    @Published public var shouldDisplayIsolatedPositionsWarning: Bool = false
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

    public var contentChanged: (() -> Void)?

    init(
        positionItems: [dydxPortfolioPositionItemViewModel] = [],
        pendingPositionItems: [dydxPortfolioPendingPositionsItemViewModel] = [],
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
        .padding(.horizontal, 16)
        .themeFont(fontSize: .small)
        .themeColor(foreground: .textTertiary)
        .wrappedViewModel
    }

    private var openPositionsView: some View {
        LazyVStack {
            let items = self.positionItems.map { $0.createView() }
            ForEach(items.indices, id: \.self) { index in
                items[index]
            }
        }
    }

    private var pendingPositionsView: AnyView? {
        let unopenedItems = self.pendingPositionItems.map { $0.createView() }
        return LazyVStack {
            self.pendingPositionsHeader?.createView()

            ForEach(unopenedItems.indices, id: \.self) { index in
                unopenedItems[index]
            }
        }
        .wrappedInAnyView()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            if let emptyText = self.emptyText, positionItems.isEmpty, pendingPositionItems.isEmpty {
                return AnyView(
                    PlaceholderViewModel(text: emptyText)
                        .createView(parentStyle: style)
                )
            }

            return AnyView(
                ScrollView {
                    VStack(spacing: 24) {
                        self.openPositionsView
                        self.pendingPositionsView
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
