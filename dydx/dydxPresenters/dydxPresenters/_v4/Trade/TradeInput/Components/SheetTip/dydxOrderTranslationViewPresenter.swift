//
//  dydxOrderTranslationViewPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 1/18/24.
//

import dydxViews
import Abacus
import dydxStateManager
import Combine
import dydxFormatter

private protocol dydxOrderTranslationViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOrderTranslationViewModel? { get }
}

class dydxOrderTranslationViewPresenter: HostedViewPresenter<dydxOrderTranslationViewModel>, dydxOrderTranslationViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxOrderTranslationViewModel()
    }

    override func start() {
        super.start()

        Publishers
            .CombineLatest(
                AbacusStateManager.shared.state.tradeInput.compactMap { $0 },
                AbacusStateManager.shared.state.configsAndAssetMap
            )
            .sink { [weak self] tradeInput, _ in
                self?.updateViewModel(tradeInput: tradeInput)
            }
            .store(in: &subscriptions)
    }

    private func updateViewModel(tradeInput: TradeInput) {
        guard let tradeType = tradeInput.type,
              let size = tradeInput.size?.size?.doubleValue,
              let side = tradeInput.side,
              let market = tradeInput.marketId,
              size > 0 else {
            viewModel?.text = AttributedString("More input needed")
                .themeColor(foreground: .textTertiary)
            return
        }
        let sideText = side.rawValue.lowercased()
        let limitPrice = dydxFormatter.shared.dollarDecimalOnlyIfNecessary(number: tradeInput.price?.limitPrice?.doubleValue)
        let triggerPrice = dydxFormatter.shared.dollarDecimalOnlyIfNecessary(number: tradeInput.price?.triggerPrice?.doubleValue)

        let limitClause: String?
        if let limitPrice = limitPrice {
            let limitDirection = side == .buy ? "below" : "above"
            limitClause = "only while the price is \(limitDirection) \(limitPrice)"
        } else {
            limitClause = nil
        }

        let triggerClause: String?
        if let triggerPrice = triggerPrice {
            let triggerDirection: String
            switch tradeType {
            case .stoplimit, .stopmarket:
                triggerDirection = side == .sell ? "falls below" : "rises above"
            case .takeprofitlimit, .takeprofitmarket:
                triggerDirection = side == .sell ? "rises above" : "falls below"
            default:
                return
            }
            triggerClause = "If the price \(triggerDirection) \(triggerPrice),"
        } else {
            triggerClause = nil
        }

        let text: String
        switch tradeType {
        case .market:
            text = "This market order will \(sideText) \(size) \(market) immediately at the market price."
        case .limit:
            guard let limitClause = limitClause else { return }
            text = "This limit order will \(sideText) \(size) \(market) \(limitClause)."
        case .stoplimit:
            guard let limitClause = limitClause, let triggerClause = triggerClause else { return }
            text = "\(triggerClause) this stop limit order will \(sideText) \(size) \(market) \(limitClause)."
        case .stopmarket:
            guard let triggerClause = triggerClause else { return }
            text = "\(triggerClause) this stop market order will \(sideText) \(size) \(market)."
        case .takeprofitlimit:
            guard let limitClause = limitClause, let triggerClause = triggerClause else { return }
            text = "\(triggerClause) this take profit limit order will \(sideText) \(size) \(market) \(limitClause)."
        case .takeprofitmarket:
            guard let triggerClause = triggerClause else { return }
            text = "\(triggerClause) this take profit market order will \(sideText) \(size) \(market)."
        default:
            text = "More input needed"
        }

        let highlightTexts: [String] = [
            "market order",
            "limit order",
            "stop limit order",
            "stop market order",
            "take profit limit order",
            "take profit market order",
            market,
            "\(size)",
            sideText,
            limitPrice,
            triggerPrice
        ].compactMap { $0 }
        var attributedText = AttributedString(text)
            .themeColor(foreground: .textTertiary)
        for highlightText in highlightTexts {
            var searchStartIndex = text.startIndex

            // need to replace all occurences, not just the first
            while searchStartIndex < text.endIndex,
                  let range = text.range(of: highlightText, range: searchStartIndex..<text.endIndex) {
                attributedText = attributedText.themeColor(foreground: .textSecondary, to: .init(range, in: attributedText))

                searchStartIndex = range.upperBound
            }
        }
        viewModel?.text = attributedText
    }
}
