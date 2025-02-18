//
//  dydxPortfolioOrdersView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxPortfolioOrderItemViewModel: PlatformViewModel {

    public struct Handler: Hashable {
        public static func == (lhs: Handler, rhs: Handler) -> Bool {
            true
        }

        public func hash(into hasher: inout Hasher) { }

        public var onTapAction: (() -> Void)?
        public var onCloseAction: (() -> Void)?
    }

    @Published public var id: String?
    @Published public var date: Date?
    @Published public var status: String?
    @Published public var canCancel: Bool = false
    @Published public var orderStatus = OrderStatusModel()
    @Published public var sideText = SideTextViewModel()
    @Published public var type: String?
    @Published public var size: String?
    @Published public var filledSize: String?
    @Published public var price: String?
    @Published public var triggerPrice: String?
    @Published public var token: TokenTextViewModel?
    @Published public var logoUrl: URL?
    @Published public var handler: Handler?

    public init(id: String? = nil, date: Date? = nil, status: String? = nil, canCancel: Bool = false, orderStatus: OrderStatusModel = OrderStatusModel(), sideText: SideTextViewModel = SideTextViewModel(), type: String? = nil, size: String? = nil, filledSize: String? = nil, price: String? = nil, triggerPrice: String? = nil, token: TokenTextViewModel? = nil, logoUrl: URL? = nil, onTapAction: (() -> Void)? = nil) {
        self.id = id
        self.date = date
        self.status = status
        self.canCancel = canCancel
        self.orderStatus = orderStatus
        self.sideText = sideText
        self.type = type
        self.size = size
        self.filledSize = filledSize
        self.price = price
        self.triggerPrice = triggerPrice
        self.token = token
        self.logoUrl = logoUrl
        self.handler = Handler(onTapAction: onTapAction)
    }

    public static var previewValue: dydxPortfolioOrderItemViewModel {
        let vm = dydxPortfolioOrderItemViewModel(
            id: "id",
            status: "Open",
            orderStatus: .previewValue,
            sideText: .previewValue,
            type: "Market Order",
            size: "200",
            filledSize: "100",
            price: "$12.00",
            token: .previewValue,
            logoUrl: URL(string: "https://media.dydx.exchange/currencies/eth.png"))
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let icon = self.createLogo(parentStyle: style)

            let main = self.createMain(parentStyle: style)

            let cell = PlatformTableViewCellViewModel(logo: icon.wrappedViewModel,
                                                      main: main.wrappedViewModel,
                                                      trailing: PlatformView.nilViewModel,
                                                      edgeInsets: EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .createView(parentStyle: parentStyle)
                        .onTapGesture { [weak self] in
                            self?.handler?.onTapAction?()
                        }

            if self.canCancel {
                let rightCellSwipeAccessoryView = PlatformIconViewModel(type: .asset(name: "action_cancel", bundle: Bundle.dydxView), size: .init(width: 16, height: 16))
                    .createView(parentStyle: style, styleKey: styleKey)
                    .tint(ThemeColor.SemanticColor.layer2.color)

                let rightCellSwipeAccessory = CellSwipeAccessory(accessoryView: AnyView(rightCellSwipeAccessoryView)) {
                    self.handler?.onCloseAction?()
                }
                return AnyView(cell.swipeActions(leftCellSwipeAccessory: nil, rightCellSwipeAccessory: rightCellSwipeAccessory))
            } else {
                return AnyView(cell)
            }
        }
    }

    private func createLogo(parentStyle: ThemeStyle) -> some View {
        HStack(spacing: 4) {
            if let date = date {
                IntervalTextModel(date: date)
                    .createView(parentStyle: parentStyle
                        .themeFont(fontSize: .smaller)
                        .themeColor(foreground: .textTertiary))
                    .frame(width: 32)
            } else {
                Text("-")
                    .themeFont(fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
                    .frame(width: 32)
            }

            ZStack {
                PlatformIconViewModel(type: .url(url: logoUrl),
                                      clip: .defaultCircle,
                                      size: CGSize(width: 32, height: 32),
                                      backgroundColor: .colorWhite)
                .createView(parentStyle: parentStyle)

                Group {
                    orderStatus.createView(parentStyle: parentStyle)
                        .rightAligned()
                        .topAligned()
                }
                .frame(width: 42, height: 42)
            }
        }

    }

    private func createMain(parentStyle: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(status ?? "")
                    .themeFont(fontSize: .small)

                Spacer()

                HStack(spacing: 2) {
                    sideText
                        .createView(parentStyle: parentStyle.themeFont(fontSize: .small))

                    Text("@")
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)

                    Text(price ?? "")
                        .themeFont(fontType: .number, fontSize: .small)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }

            HStack {
                HStack(spacing: 2) {
                    Text(filledSize ?? "")
                    Text("/")
                    Text(size ?? "")
                    token?.createView(parentStyle: parentStyle.themeFont(fontSize: .smallest))
                }
                .themeFont(fontType: .number, fontSize: .smaller)
                .themeColor(foreground: .textTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

                Spacer()

                Text(type ?? "")
                    .themeFont(fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
            }
        }

    }
}

public class dydxPortfolioOrdersViewModel: PlatformListViewModel {
    @Published public var placeholderText: String?

    public override var placeholder: PlatformViewModel? {
        let vm = PlaceholderViewModel()
        vm.text = placeholderText
        return vm
    }

    public init(items: [PlatformViewModel] = [], contentChanged: (() -> Void)? = nil) {
        super.init(items: items,
                   intraItemSeparator: true,
                   firstListItemTopSeparator: true,
                   lastListItemBottomSeparator: true,
                   contentChanged: contentChanged)
    }

    public static var previewValue: dydxPortfolioOrdersViewModel {
        let vm = dydxPortfolioOrdersViewModel()
        vm.items = [
            dydxPortfolioOrderItemViewModel.previewValue,
            dydxPortfolioOrderItemViewModel.previewValue
        ]
        return vm
    }

    public override var header: PlatformViewModel? {
        guard items.count > 0 else { return nil }
        return HStack {
            Text(DataLocalizer.localize(path: "APP.GENERAL.STATUS_FILL"))
            Spacer()
            Text(DataLocalizer.localize(path: "APP.GENERAL.PRICE_TYPE"))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .themeFont(fontSize: .small)
        .themeColor(foreground: .textTertiary)
        .wrappedViewModel
    }
}

#if DEBUG
struct dydxPortfolioOrdersView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return ScrollView(showsIndicators: false) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                dydxPortfolioOrdersViewModel.previewValue
                    .createView()
            }
            .previewLayout(.sizeThatFits)
        }
    }
}

struct dydxPortfolioOrdersView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return ScrollView(showsIndicators: false) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                dydxPortfolioOrdersViewModel.previewValue
                    .createView()
            }
            .previewLayout(.sizeThatFits)
        }
    }
}
#endif
