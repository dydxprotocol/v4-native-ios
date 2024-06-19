//
//  dydxCancelPendingIsolatedOrdersView.swift
//  dydxViews
//
//  Created by Michael Maguire on 6/17/24.
//

import SwiftUI
import PlatformUI
import Utilities
import SDWebImageSwiftUI

public class dydxCancelPendingIsolatedOrdersViewModel: PlatformViewModel {
    public enum State {
        case readyToSubmit
        case failed
        case submitting
        case resubmitting
    }

    @Published public var state: State = .readyToSubmit

    @Published public var marketLogoUrl: URL?
    @Published public var marketName: String
    @Published public var marketId: String
    @Published public var orderCount: Int
    @Published public var failureCount: Int?
    @Published public var cancelAction: (() -> Void)

    public init(marketLogoUrl: URL?,
                marketName: String,
                marketId: String,
                orderCount: Int,
                failureCount: Int? = nil,
                cancelAction: @escaping (() -> Void)
    ) {
        self.marketLogoUrl = marketLogoUrl
        self.marketName = marketName
        self.marketId = marketId
        self.orderCount = orderCount
        self.failureCount = failureCount
        self.cancelAction = cancelAction
    }

    public static var previewValue: dydxCancelPendingIsolatedOrdersViewModel {
        .init(marketLogoUrl: URL(string: "https://v4.testnet.dydx.exchange/currencies/eth.png"),
              marketName: "Ethereum",
              marketId: "ETH-USDC",
              orderCount: 1,
              failureCount: nil,
              cancelAction: {}
        )
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            switch self.state {
            case .readyToSubmit, .submitting:
                return CancelView(viewModel: self).wrappedInAnyView()
            case .failed, .resubmitting:
                return TryAgainView(viewModel: self).wrappedInAnyView()
            }
        }
    }
}

private struct TryAgainView: View {
    @StateObject var viewModel = dydxCancelPendingIsolatedOrdersViewModel.previewValue

    var errorImage: some View {
        Image("icon_error", bundle: .dydxView)
            .resizable()
            .templateColor(.colorRed)
            .scaledToFit()
            .frame(width: 40, height: 40)
            .padding(.all, 20)
            .themeColor(background: .layer3)
            .clipShape(.circle)
    }

    var title: some View {
        if let failureCount = viewModel.failureCount {
            let key = viewModel.failureCount == 1 ? "APP.TRADE.CANCELING_ONE_ORDER_FAILED" : "APP.TRADE.CANCELING_N_ORDERS_FAILED"
            let params = ["COUNT": "\(failureCount)"]
            return Text(localizerPathKey: key, params: params)
                .themeFont(fontType: .plus, fontSize: .largest)
                .themeColor(foreground: .textPrimary)
        } else {
            return Text("")
        }

    }

    var button: some View {
        let content: Text
        let buttonState: PlatformButtonState = viewModel.state == .resubmitting ? .disabled : .destructive
        if viewModel.state == .resubmitting {
            content = Text(localizerPathKey: "APP.TRADE.CANCELING_ORDERS_COUNT", params: ["COUNT": "\(viewModel.orderCount)"])
                .themeFont(fontType: .base, fontSize: .medium)
                .themeColor(foreground: .textTertiary)
        } else {
            content = Text(localizerPathKey: "APP.ONBOARDING.TRY_AGAIN")
                .themeFont(fontType: .base, fontSize: .medium)
                .themeColor(foreground: .textPrimary)
        }
        return PlatformButtonViewModel(content: content.wrappedViewModel,
                                       type: .defaultType(),
                                       state: buttonState,
                                       action: viewModel.cancelAction)
            .createView()
    }

    var body: some View {
        VStack(spacing: 24) {
            errorImage
            title
            button
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, max((safeAreaInsets?.bottom ?? 0), 24))
        .themeColor(background: .layer4)
        .makeSheet(sheetStyle: .fitSize)
        .ignoresSafeArea(edges: [.bottom])
    }
}

private struct CancelView: View {
    @StateObject var viewModel = dydxCancelPendingIsolatedOrdersViewModel.previewValue

    var logo: some View {
        return WebImage(url: viewModel.marketLogoUrl)
            .resizable()
            .scaledToFit()
            .frame(width: 85, height: 85)
            .clipShape(.circle)
    }

    var title: some View {
        return Text(localizerPathKey: "APP.TRADE.CANCEL_ORDERS")
            .themeFont(fontType: .plus, fontSize: .largest)
            .themeColor(foreground: .textPrimary)
    }

    var subtitle: some View {
        let openOrdersText = (viewModel.orderCount == 1 ?
            DataLocalizer.shared?.localize(path: "APP.CANCEL_ORDERS_MODAL.ONE_OPEN_ORDER", params: nil)
            : DataLocalizer.shared?.localize(path: "APP.CANCEL_ORDERS_MODAL.N_OPEN_ORDERS", params: ["COUNT": "\(viewModel.orderCount)"])) ?? ""

        let localizedString = DataLocalizer.shared?.localize(path: "APP.CANCEL_ORDERS_MODAL.CANCEL_ORDERS_CONFIRMATION", params: ["OPEN_ORDERS_TEXT": openOrdersText,
                                                                                                                                  "ASSET": viewModel.marketName,
                                                                                                                                  "MARKET": viewModel.marketId]) ?? ""
        var attributedString = AttributedString(localizedString)
            .themeFont(fontType: .base, fontSize: .small)
            .themeColor(foreground: .textTertiary, to: nil)

        let replacementTexts = [
            openOrdersText,
            viewModel.marketName,
            viewModel.marketId
        ]
        for replacementText in replacementTexts {
            if let range = attributedString.range(of: replacementText) {
                attributedString = attributedString.themeColor(foreground: .textSecondary, to: range)
            }
        }

        return Text(attributedString)
            .multilineTextAlignment(.center)

    }

    var button: some View {
        let content: Text
        let buttonState: PlatformButtonState = viewModel.state == .submitting ? .disabled : .destructive
        if viewModel.state == .submitting {
            content = Text(localizerPathKey: "APP.TRADE.CANCELING_ORDERS_COUNT", params: ["COUNT": "\(viewModel.orderCount)"])
                .themeFont(fontType: .base, fontSize: .medium)
                .themeColor(foreground: .textTertiary)
        } else {
            let key = viewModel.orderCount == 1 ? "APP.TRADE.CANCEL_ORDER" : "APP.TRADE.CANCEL_ORDERS_COUNT"
            let params = ["COUNT": "\(viewModel.orderCount)"]
            content = Text(localizerPathKey: key, params: params)
                .themeFont(fontType: .base, fontSize: .medium)
                .themeColor(foreground: .colorRed)
        }
        return PlatformButtonViewModel(content: content.wrappedViewModel,
                                       type: .defaultType(),
                                       state: buttonState,
                                       action: viewModel.cancelAction)
            .createView()
    }

    var body: some View {
        VStack(spacing: 24) {
            logo
            VStack(spacing: 8) {
                title
                subtitle
            }
            button
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, max((viewModel.safeAreaInsets?.bottom ?? 0), 24))
        .themeColor(background: .layer4)
        .makeSheet(sheetStyle: .fitSize)
        .ignoresSafeArea(edges: [.bottom])
    }
}

#Preview {
    CancelView()
}
