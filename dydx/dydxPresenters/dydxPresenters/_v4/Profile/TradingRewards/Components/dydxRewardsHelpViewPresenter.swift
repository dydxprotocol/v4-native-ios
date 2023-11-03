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

public protocol dydxRewardsHelpViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxRewardsHelpViewModel? { get }
}

public class dydxRewardsHelpViewPresenter: HostedViewPresenter<dydxRewardsHelpViewModel>, dydxRewardsHelpViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxRewardsHelpViewModel()

        viewModel?.learnMoreTapped = {
            // TODO get url from abacus
//            Router.shared?.navigate(to: .init(url: ...), animated: true, completion: nil)
        }

        let faqs = AbacusStateManager.shared.documentation?.tradingRewardsFAQs.map { faq in
            dydxFAQViewModel(questionLocalizationKey: faq.questionLocalizationKey, answerLocalizationKey: faq.answerLocalizationKey)
        }
        if let faqs {
            viewModel?.faqs = faqs
        }
    }
}
