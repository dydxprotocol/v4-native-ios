//
//  dydxRewardsHelpViewPresenter.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 12/5/23.
//

import dydxViews
import PlatformParticles
import ParticlesKit
import RoutingKit
import dydxStateManager
import Abacus
import Utilities

public protocol dydxRewardsHelpViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxRewardsHelpViewModel? { get }
}

public class dydxRewardsHelpViewPresenter: HostedViewPresenter<dydxRewardsHelpViewModel>, dydxRewardsHelpViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxRewardsHelpViewModel()

        viewModel?.learnMoreTapped = {
            if let urlString = AbacusStateManager.shared.environment?.links?.tradingRewardsLearnMore,
               let url = URL(string: urlString) {
                if URLHandler.shared?.canOpenURL(url) ?? false {
                    URLHandler.shared?.open(url, completionHandler: nil)
                }
            }
        }

        let faqs = AbacusStateManager.shared.documentation?.tradingRewardsFAQs.map { faq in
            dydxFAQViewModel(questionLocalizationKey: faq.questionLocalizationKey, answerLocalizationKey: faq.answerLocalizationKey)
        }
        if let faqs {
            viewModel?.faqs = faqs
        }
    }
}
