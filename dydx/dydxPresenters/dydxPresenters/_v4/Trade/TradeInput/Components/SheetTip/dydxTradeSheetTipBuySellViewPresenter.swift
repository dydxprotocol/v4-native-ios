//
//  dydxTradeSheetTipBuySellViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 9/26/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager

protocol dydxTradeSheetTipBuySellViewPresenterDelegate: AnyObject {
    func buySellButtonTapped()
}

protocol dydxTradeSheetTipBuySellViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeSheetTipBuySellViewModel? { get }
}

class dydxTradeSheetTipBuySellViewPresenter: HostedViewPresenter<dydxTradeSheetTipBuySellViewModel>, dydxTradeSheetTipBuySellViewPresenterProtocol {
    weak var delegate: dydxTradeSheetTipBuySellViewPresenterDelegate?

    override init() {
        super.init()

        viewModel = dydxTradeSheetTipBuySellViewModel()
        viewModel?.tapAction = { [weak self] option in
            AbacusStateManager.shared.trade(input: option.value, type: TradeInputField.side)
            self?.delegate?.buySellButtonTapped()
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.tradeInput
            .sink { [weak self] tradeInput in
                guard let self = self else { return }
                if let sideOptions = tradeInput?.options?.sideOptions {
                    let options = AbacusUtils.translate(options: sideOptions)
                    self.viewModel?.items = options.map { option in
                        let color = option.value.uppercased() == "BUY" ? ThemeSettings.positiveColor : ThemeSettings.negativeColor
                        return dydxTradeSheetTipBuySellViewModel.Item(option: option, color: color)
                    }
                }
            }
            .store(in: &subscriptions)
    }
}
