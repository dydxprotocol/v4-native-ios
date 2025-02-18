//
//  dydxPortfolioPendingPositionsItemViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 6/12/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxPortfolioPendingPositionsItemViewModel: PlatformViewModel {
    @Published public var marketLogoUrl: URL?
    @Published public var marketName: String
    @Published public var margin: String
    @Published public var orderCount: Int32
    @Published public var viewOrdersAction: (() -> Void)
    @Published public var cancelOrdersAction: (() -> Void)

    public init(marketLogoUrl: URL?,
         marketName: String,
         margin: String,
         orderCount: Int32,
         viewOrdersAction: @escaping () -> Void,
         cancelOrdersAction: @escaping () -> Void) {
        self.marketLogoUrl = marketLogoUrl
        self.marketName = marketName
        self.margin = margin
        self.orderCount = orderCount
        self.viewOrdersAction = viewOrdersAction
        self.cancelOrdersAction = cancelOrdersAction
    }

    public static var previewValue: dydxPortfolioPendingPositionsItemViewModel = {
        .init(marketLogoUrl: URL(string: "https://v4.testnet.dydx.exchange/currencies/eth.png"),
              marketName: "ETH-USD",
              margin: "$1000.00",
              orderCount: 2,
              viewOrdersAction: {},
              cancelOrdersAction: {}
        )
    }()

    private var topContent: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                PlatformIconViewModel(type: .url(url: marketLogoUrl),
                                      clip: .defaultCircle,
                                      size: CGSize(width: 20, height: 20),
                                      backgroundColor: .colorWhite)
                .createView()
                Text(marketName)
                    .themeFont(fontSize: .large)
                    .themeColor(foreground: .textSecondary)
                Spacer()
            }
            HStack(spacing: 0) {
                Text(localizerPathKey: "APP.GENERAL.MARGIN")
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textTertiary)
                Spacer()
                Text(margin)
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .frame(height: 1)
            .overlay(ThemeColor.SemanticColor.borderDefault.color)
    }

    private var bottomContent: some View {
        let viewOrdersStringKey: String
        let viewOrdersStringParams: [String: String]?
        if orderCount == 1 {
            viewOrdersStringKey = "APP.GENERAL.VIEW_ORDER"
            viewOrdersStringParams = nil
        } else {
            viewOrdersStringKey = "APP.GENERAL.VIEW_ORDERS_COUNT"
            viewOrdersStringParams = ["NUM_ORDERS": "\(orderCount)"]
        }

        let viewOrders = Text(localizerPathKey: viewOrdersStringKey, params: viewOrdersStringParams)
            .themeFont(fontSize: .medium)
            .themeColor(foreground: .colorPurple)
        let cancel = Text(localizerPathKey: "APP.GENERAL.CANCEL")
            .themeFont(fontSize: .medium)
            .themeColor(foreground: .colorRed)
        return HStack(spacing: 0) {
            Button(action: viewOrdersAction, label: { viewOrders })
            Spacer()
            Button(action: cancelOrdersAction, label: { cancel })
        }
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let verticalPadding: CGFloat = 16
            let horizontalPadding: CGFloat = 20
            return VStack(spacing: 12) {
                self.topContent
                self.divider
                    .padding(.horizontal, -horizontalPadding)
                self.bottomContent
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .themeColor(background: .layer3)
            .clipShape(.rect(cornerRadius: 10))
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxPortfolioPendingPositionsItemView_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxPortfolioPendingPositionsItemViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
