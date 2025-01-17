//
//  dydxTradeInputViewBuilder.swift
//  dydxPresenter
//
//  Created by John Huang on 12/29/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Abacus
import dydxStateManager
import dydxViews
import ParticlesKit
import PlatformParticles
import PlatformUI
import RoutingKit
import Utilities
import FloatingPanel
import PlatformRouting
import Combine
import dydxFormatter

public class dydxTradeInputViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxTradeInputViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxTradeInputViewController(presenter: presenter, view: view, configuration: .default)
        presenter.delegate = viewController
        return viewController as? T
    }
}

private class dydxTradeInputViewController: HostingViewController<PlatformView, dydxTradeInputViewModel>, FloatingInsetProvider, FloatedDelegate, dydxTradeInputViewPresenterDelegate {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/input", let presenter = presenter as? dydxTradeInputViewPresenter {
            AbacusStateManager.shared.startTrade()
            if request?.params?["full"] as? String == "true" {
                presenter.updateViewControllerPosition(position: .half)
                move(to: .half)
            } else {
                presenter.updateViewControllerPosition(position: .tip)
                move(to: .tip)
            }

            presenter.viewModel?.editViewModel?.onScrollViewCreated  = { [weak self] scrollView in
                self?.floatTracking = scrollView
            }
            return true
        }
        return false
    }

    // MARK: FloatingInsetProvider, FloatedDelegate

    var anchors: [FloatingPanel.FloatingPanelState: FloatingPanel.FloatingPanelLayoutAnchoring] {
        var positions: [FloatingPanel.FloatingPanelState: FloatingPanel.FloatingPanelLayoutAnchoring] = [
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 90, edge: .bottom, referenceGuide: .safeArea),
            // Use .half instead of .full, so that the back button from the parent view is enabled.
            .half: FloatingPanelLayoutAnchor(absoluteInset: 76, edge: .top, referenceGuide: .safeArea)
        ]
        if position == nil {
            positions[.hidden] = FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .bottom, referenceGuide: .superview)
        }
        return positions
    }

    var initialPosition: FloatingPanelState = .hidden

    func floatingChanged() {
        if let presenter = presenter as? dydxTradeInputViewPresenterProtocol, let position = position {
            presenter.updateViewControllerPosition(position: position)
        }
    }

    var position: FloatingPanelState?

    var floatTracking: UIScrollView? {
        didSet {
            if let floatTracking = floatTracking {
                floatingParent?.track(scrollView: floatTracking)
            }
        }
    }

    func shouldPan(currentState: FloatingPanel.FloatingPanelState, velocity: CGPoint) -> Bool {
        if currentState == .half {
            return velocity.y > 0 // only allow panning down
        }

        return true
    }

    // MARK: dydxTradeInputViewPresenterDelegate

    func buySellButtonTapped() {
        move(to: .half)
    }
}

private protocol dydxTradeInputViewPresenterDelegate: AnyObject {
    func buySellButtonTapped()
}

private protocol dydxTradeInputViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTradeInputViewModel? { get }
    func updateViewControllerPosition(position: FloatingPanelState)
}

private class dydxTradeInputViewPresenter: HostedViewPresenter<dydxTradeInputViewModel>, dydxTradeInputViewPresenterProtocol, dydxTradeSheetTipBuySellViewPresenterDelegate {
    weak var delegate: dydxTradeInputViewPresenterDelegate?

    // MARK: dydxTradeInputViewPresenterProtocol

    func updateViewControllerPosition(position: FloatingPanel.FloatingPanelState) {
        switch position {
        case .tip:
            viewModel?.displayState = .tip
        default:
            viewModel?.displayState = .full
        }
    }

    // MARK: dydxTradeSheetTipBuySellViewPresenterDelegate

    func buySellButtonTapped() {
        viewModel?.displayState = .full
        delegate?.buySellButtonTapped()
    }

    private let orderTypePresenter = dydxTradeInputOrderTypeViewPresenter()
    private let sideViewPresenter = dydxTradeInputSideViewPresenter()
    private let orderbookPresenter = dydxOrderbookPresenter()
    private let editPresenter = dydxTradeInputEditViewPresenter()
    private let ctaButtonPresenter = dydxTradeInputCtaButtonViewPresenter()
    private let validationPresenter = dydxValidationViewPresenter(receiptType: .trade(.open))
    private let tipBuySellPresenter = dydxTradeSheetTipBuySellViewPresenter()
    private let tipDraftPresenter = dydxTradeSheetTipDraftViewPresenter()
    private let orderbookGroupPresenter = dydxOrderbookGroupViewPresenter()
    private let marginViewPresenter = dydxTradeInputMarginViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        orderTypePresenter,
        sideViewPresenter,
        orderbookPresenter,
        editPresenter,
        ctaButtonPresenter,
        validationPresenter,
        tipBuySellPresenter,
        tipDraftPresenter,
        orderbookGroupPresenter,
        marginViewPresenter
    ]

    override init() {
        let viewModel = dydxTradeInputViewModel()

        orderTypePresenter.$viewModel.assign(to: &viewModel.$orderTypeViewModel)
        sideViewPresenter.$viewModel.assign(to: &viewModel.$sideViewModel)
        orderbookPresenter.$viewModel.assign(to: &viewModel.$orderbookViewModel)
        editPresenter.$viewModel.assign(to: &viewModel.$editViewModel)
        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButtonViewModel)
        validationPresenter.$viewModel.assign(to: &viewModel.$validationViewModel)
        tipBuySellPresenter.$viewModel.assign(to: &viewModel.$tipBuySellViewModel)
        tipDraftPresenter.$viewModel.assign(to: &viewModel.$tipDraftViewModel)
        marginViewPresenter.$viewModel.assign(to: &viewModel.$marginViewModel)

        super.init()

        self.viewModel = viewModel
        tipBuySellPresenter.delegate = self

        orderbookPresenter.viewModel?.delegate = editPresenter

        orderbookGroupPresenter.$viewModel
            .sink { [weak self] groupViewModel in
                self?.viewModel?.orderbookManagerViewModel?.group = groupViewModel
            }
            .store(in: &subscriptions)

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.tradeInput
            .map(\.?.marketId)
            .assign(to: &orderbookPresenter.$marketId)

        AbacusStateManager.shared.state.tradeInput
            .map(\.?.marketId)
            .assign(to: &orderbookGroupPresenter.$marketId)

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.onboarded,
            AbacusStateManager.shared.state.selectedSubaccount
        )
            .sink { [weak self] onboarded, subAccount in
                self?.viewModel?.isShowingValidation = onboarded && subAccount?.equity?.current?.doubleValue ?? 0 > 0
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.tradeInput
            .map(\.?.size)
            .sink { [weak self] size in
                let size = self?.parser.asNumber(size?.size)?.doubleValue ?? 0
                self?.viewModel?.tipState = size > 0 ? .draft : .buySell
            }
            .store(in: &subscriptions)

    }
}
