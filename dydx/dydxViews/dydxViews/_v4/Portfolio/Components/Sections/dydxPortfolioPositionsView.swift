//
//  dydxPortfolioPositionsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import dydxFormatter
import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioPositionItemViewModel: PlatformViewModel {
    public struct Handler: Hashable {
        public static func == (lhs: dydxPortfolioPositionItemViewModel.Handler, rhs: dydxPortfolioPositionItemViewModel.Handler) -> Bool {
            true
        }

        public func hash(into hasher: inout Hasher) { }

        public var onTapAction: (() -> Void)?
        public var onCloseAction: (() -> Void)?
    }

    public init(size: String? = nil, token: TokenTextViewModel? = TokenTextViewModel(), sideText: SideTextViewModel = SideTextViewModel(), leverage: String? = nil, leverageIcon: LeverageRiskModel? = nil, indexPrice: String? = nil, entryPrice: String? = nil, unrealizedPnlPercent: SignedAmountViewModel? = nil, unrealizedPnl: SignedAmountViewModel? = nil, logoUrl: URL? = nil, gradientType: GradientType = .none, onTapAction: (() -> Void)? = nil) {
        self.size = size
        self.token = token
        self.sideText = sideText
        self.leverage = leverage
        self.leverageIcon = leverageIcon
        self.indexPrice = indexPrice
        self.entryPrice = entryPrice
        self.unrealizedPnlPercent = unrealizedPnlPercent
        self.unrealizedPnl = unrealizedPnl
        self.gradientType = gradientType
        self.logoUrl = logoUrl
        self.handler = Handler(onTapAction: onTapAction)
    }

    public var size: String?
    public var token: TokenTextViewModel?
    public var sideText = SideTextViewModel()
    public var leverage: String?
    public var leverageIcon: LeverageRiskModel?
    public var indexPrice: String?
    public var entryPrice: String?
    public var unrealizedPnlPercent: SignedAmountViewModel?
    public var unrealizedPnl: SignedAmountViewModel?
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
            unrealizedPnlPercent: .previewValue,
            unrealizedPnl: .previewValue,
            logoUrl: URL(string: "https://media.dydx.exchange/currencies/eth.png"),
            gradientType: .plus)
        return item
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let icon = self.createLogo(parentStyle: style)

            let main = self.createMain(parentStyle: style)

            let trailing = self.createTrailing(parentStyle: style)

            let cell = PlatformTableViewCellViewModel(logo: icon.wrappedViewModel,
                                                      main: main.wrappedViewModel,
                                                      trailing: trailing.wrappedViewModel)
                               .createView(parentStyle: parentStyle)
                               .frame(height: 64)
                               .themeGradient(background: .layer3, gradientType: self.gradientType)
                               .cornerRadius(16)
                               .onTapGesture { [weak self] in
                                   self?.handler?.onTapAction?()
                               }

            let rightCellSwipeAccessoryView = PlatformIconViewModel(type: .asset(name: "action_cancel", bundle: Bundle.dydxView), size: .init(width: 16, height: 16))
                .createView(parentStyle: style, styleKey: styleKey)
                .tint(ThemeColor.SemanticColor.layer2.color)

            let rightCellSwipeAccessory = CellSwipeAccessory(accessoryView: AnyView(rightCellSwipeAccessoryView)) {
                self.handler?.onCloseAction?()
            }

            return AnyView(
                cell.swipeActions(leftCellSwipeAccessory: nil, rightCellSwipeAccessory: rightCellSwipeAccessory)
            )
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

    private func createMain(parentStyle: ThemeStyle) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 2) {
                    Text(size ?? "")
                        .themeFont(fontType: .number, fontSize: .small)

                    token?.createView(parentStyle: parentStyle.themeFont(fontSize: .smallest))
                }

                if !dydxBoolFeatureFlag.enable_spot_experience.isEnabled {
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
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(indexPrice ?? "")
                    .themeFont(fontType: .number, fontSize: .small)
                    .lineLimit(1)

                Text(entryPrice ?? "")
                    .themeFont(fontType: .number, fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
                    .lineLimit(1)
            }
        }
        .minimumScaleFactor(0.5)
    }

    private func createTrailing(parentStyle: ThemeStyle) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                unrealizedPnlPercent?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .small))

                unrealizedPnl?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .smaller))
            }
        }
        .frame(maxWidth: 80)
    }
}

public class dydxPortfolioPositionsViewModel: PlatformListViewModel {
    @Published public var placeholderText: String? {
        didSet {
            _placeholder.text = placeholderText
        }
    }

    private let _placeholder = PlaceholderViewModel()

    public override init(items: [PlatformViewModel] = [], header: PlatformViewModel? = nil, placeholder: PlatformViewModel? = nil, intraItemSeparator: Bool = false, firstListItemTopSeparator: Bool = false, lastListItemBottomSeparator: Bool = false, contentChanged: (() -> Void)? = nil) {
        super.init(items: items, header: header, placeholder: placeholder, intraItemSeparator: intraItemSeparator, firstListItemTopSeparator: firstListItemTopSeparator, lastListItemBottomSeparator: lastListItemBottomSeparator, contentChanged: contentChanged)
        self.placeholder = _placeholder
        self.header = createHeader().wrappedViewModel
        self.width = UIScreen.main.bounds.width - 32
    }

    public static var previewValue: dydxPortfolioPositionsViewModel {
        let vm = dydxPortfolioPositionsViewModel {}
        vm.items = [
            dydxPortfolioPositionItemViewModel.previewValue,
            dydxPortfolioPositionItemViewModel.previewValue
        ]
        return vm
    }

    private func createHeader() -> some View {
        HStack {
            Text(DataLocalizer.localize(path: "APP.GENERAL.DETAILS"))
            Spacer()
            Text(DataLocalizer.localize(path: "APP.GENERAL.INDEX_ENTRY"))

            HStack {
                Spacer()
                Text(DataLocalizer.localize(path: "APP.GENERAL.PROFIT_AND_LOSS"))
            }
            .frame(maxWidth: 80)
        }
        .padding(.horizontal, 16)
        .themeFont(fontSize: .small)
        .themeColor(foreground: .textTertiary)
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
