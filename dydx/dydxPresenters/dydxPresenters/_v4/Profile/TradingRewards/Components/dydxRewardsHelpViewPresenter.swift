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

        // TODO get todos from abacus
        viewModel?.faqs = [
            .init(question: "What is the question?", answer: "The answer to your question is he answer to your question is The answer to your question is The answer to your question is "),
            .init(question: "What is the question if the question is the question about a question?", answer: "The answer to your question is he answer to your question is The answer to your question is The answer to your question is "),
            .init(question: "What is the question again?", answer: "The answer to your question is he answer to your question is The answer to your question is The answer to your question is "),
            .init(question: "What is the question again again again?", answer: "The answer to your question is he answer to your question is The answer to your question is The answer to your question is ")
        ]
    }
}
