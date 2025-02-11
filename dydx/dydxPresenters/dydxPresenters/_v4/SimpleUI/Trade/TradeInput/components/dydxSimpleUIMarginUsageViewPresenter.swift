//
//  dydxSimpleUIMarginUsageViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 19/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import SwiftUI
import Combine
import dydxFormatter
import Abacus
import dydxStateManager

protocol dydxSimpleUIMarginUsageViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIMarginUsageViewModel? { get }
}

class dydxSimpleUIMarginUsageViewPresenter: HostedViewPresenter<dydxSimpleUIMarginUsageViewModel>, dydxSimpleUIMarginUsageViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxSimpleUIMarginUsageViewModel()

        viewModel?.learnMoreAction = {
            if let urlString = AbacusStateManager.shared.environment?.links?.simpleTradeLearnMore,
               let url = URL(string: urlString) {
                if URLHandler.shared?.canOpenURL(url) ?? false {
                    URLHandler.shared?.open(url, completionHandler: nil)
                }
            }
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.selectedSubaccount
            .compactMap { $0 }
            .sink { [weak self] account in
                self?.updateMarginUsageChange(account: account)
            }
            .store(in: &subscriptions)
    }

    private func updateMarginUsageChange(account: Subaccount) {
        let before: Double?
        if let beforeAmount = account.marginUsage?.current {
            before = beforeAmount.doubleValue
        } else {
            before = nil
        }

        let after: Double?
        if let afterAmount = account.marginUsage?.postOrder, afterAmount != account.marginUsage?.current {
            after = afterAmount.doubleValue
        } else {
            after = nil
        }

        viewModel?.marginUsage = after ?? before
    }

}
