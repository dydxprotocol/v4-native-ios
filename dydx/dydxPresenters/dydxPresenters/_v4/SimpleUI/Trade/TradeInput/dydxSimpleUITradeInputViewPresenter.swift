//
//  dydxSimpleUITradeInputViewModelPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 27/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import FloatingPanel
import PlatformRouting
import Combine
import dydxFormatter

public class dydxSimpleUITradeInputViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxSimpleUITradeInputViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxSimpleUITradeInputViewController(presenter: presenter, view: view, configuration: .default)
        presenter.delegate = viewController
        return viewController as? T
    }
}

class dydxSimpleUITradeInputViewController: HostingViewController<PlatformView, dydxSimpleUITradeInputViewModel>, FloatingInsetProvider, FloatedDelegate, dydxSimpeUITradeInputViewPresenterDelegate {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/trade/input", let presenter = presenter as? dydxSimpleUITradeInputViewPresenter {

            AbacusStateManager.shared.startTrade()
            AbacusStateManager.shared.trade(input: "MARKET", type: .type)
            AbacusStateManager.shared.trade(input: "0", type: .size)
            AbacusStateManager.shared.trade(input: "0", type: .usdcsize)
            AbacusStateManager.shared.trade(input: nil, type: .size)
            AbacusStateManager.shared.trade(input: nil, type: .usdcsize)

            if request?.params?["full"] as? String == "true" {
                presenter.updateViewControllerPosition(position: .half)
                move(to: .half)
            } else {
                presenter.updateViewControllerPosition(position: .tip)
                move(to: .tip)
            }

            presenter.viewModel?.onScrollViewCreated  = { [weak self] scrollView in
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
            .half: FloatingPanelLayoutAnchor(absoluteInset: 58, edge: .top, referenceGuide: .safeArea)
        ]
        if position == nil {
            positions[.hidden] = FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .bottom, referenceGuide: .superview)
        }
        return positions
    }

    var initialPosition: FloatingPanelState = .hidden

    func floatingChanged() {
        if let presenter = presenter as? dydxSimpleUITradeInputViewPresenterProtocol, let position = position {
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

    // MARK: dydxSimpeUITradeInputViewPresenterDelegate

    func buySellButtonTapped() {
        move(to: .half)
    }

    func tradeButtonTapped() {
        move(to: .tip)
    }
}

private protocol dydxSimpeUITradeInputViewPresenterDelegate: AnyObject {
    func buySellButtonTapped()
    func tradeButtonTapped()
}

private protocol dydxSimpleUITradeInputViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUITradeInputViewModel? { get }
    func updateViewControllerPosition(position: FloatingPanelState)
}

private class dydxSimpleUITradeInputViewPresenter: HostedViewPresenter<dydxSimpleUITradeInputViewModel>, dydxSimpleUITradeInputViewPresenterProtocol, dydxTradeSheetTipBuySellViewPresenterDelegate, dydxSimpleUITradeInputCtaButtonViewPresenterDelegate {

    weak var delegate: dydxSimpeUITradeInputViewPresenterDelegate?

    private var lastSizeFocusState: dydxSimpleUITradeInputSizeViewModel.FocusState?

    // MARK: dydxTradeInputViewPresenterProtocol

    func updateViewControllerPosition(position: FloatingPanel.FloatingPanelState) {
        switch position {
        case .tip:
            viewModel?.displayState = .tip
            if sizeViewPresenter.viewModel?.focusState != dydxSimpleUITradeInputSizeViewModel.FocusState.none {
                lastSizeFocusState = sizeViewPresenter.viewModel?.focusState
            }
            sizeViewPresenter.updateFocusState(.none)
        default:
            viewModel?.displayState = .full
            if let lastSizeFocusState, lastSizeFocusState != dydxSimpleUITradeInputSizeViewModel.FocusState.none {
                sizeViewPresenter.updateFocusState(lastSizeFocusState)
            } else {
                sizeViewPresenter.updateFocusState(.atUsdcSize)
            }
        }
    }

    // MARK: dydxTradeSheetTipBuySellViewPresenterDelegate

    func buySellButtonTapped() {
        viewModel?.displayState = .full
        delegate?.buySellButtonTapped()
    }

    // MARK: dydxSimpleUITradeInputCtaButtonViewPresenterDelegate

    func tradeButtonTapped() {
        delegate?.tradeButtonTapped()
    }

    private let tipBuySellPresenter = dydxTradeSheetTipBuySellViewPresenter()
    private let tipDraftPresenter = dydxTradeSheetTipDraftViewPresenter()
    private let sideViewPresenter = dydxTradeInputSideViewPresenter()
    private let ctaButtonPresenter = dydxSimpleUITradeInputCtaButtonViewPresenter()
    private let sizeViewPresenter = dydxSimpleUITradeInputSizeViewPresenter()

    private let receiptPresenter = dydxTradeReceiptPresenter(tradeReceiptType: .open)
    private let validationErrorPresenter = dydxSimpleUITradeInputValidationViewPresenter()

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        tipBuySellPresenter,
        tipDraftPresenter,
        sideViewPresenter,
        ctaButtonPresenter,
        sizeViewPresenter,
        receiptPresenter,
        validationErrorPresenter
    ]

    override init() {
        let viewModel = dydxSimpleUITradeInputViewModel()

        tipBuySellPresenter.$viewModel.assign(to: &viewModel.$tipBuySellViewModel)
        tipDraftPresenter.$viewModel.assign(to: &viewModel.$tipDraftViewModel)
        sideViewPresenter.$viewModel.assign(to: &viewModel.$sideViewModel)
        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButtonViewModel)
        sizeViewPresenter.$viewModel.assign(to: &viewModel.$sizeViewModel)
        receiptPresenter.$buyingPowerViewModel.assign(to: &viewModel.$buyingPowerViewModel)
        validationErrorPresenter.$viewModel.assign(to: &viewModel.$validationErrorViewModel)

        super.init()

        self.viewModel = viewModel
        tipBuySellPresenter.delegate = self
        ctaButtonPresenter.delegate = self

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.tradeInput
            .map(\.?.size)
            .sink { [weak self] size in
                let size = self?.parser.asNumber(size?.size)?.doubleValue ?? 0
                self?.viewModel?.tipState = size > 0 ? .draft : .buySell
            }
            .store(in: &subscriptions)
    }
}
