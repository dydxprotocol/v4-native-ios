//
//  dydxTransferOutViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 8/15/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxFormatter
import Combine

protocol dydxTransferOutViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferOutViewModel? { get }
}

class dydxTransferOutViewPresenter: HostedViewPresenter<dydxTransferOutViewModel>, dydxTransferOutViewPresenterProtocol {
    private let validationPresenter = dydxValidationViewPresenter(receiptType: .transfer)
    private let ctaButtonPresenter = dydxTransferInputCtaButtonViewPresenter(transferType: .transferOut)

    private var chains: [SelectionOption] = []
    private var tokens: [SelectionOption] = []
    private var selectedChain: SelectionOption? {
        didSet {
            if selectedChain != oldValue {
                updateChainsTokensViewModel()
            }
        }
    }
    @Published private var selectedToken: SelectionOption? {
        didSet {
            if selectedToken != oldValue {
                updateChainsTokensViewModel()
            }
        }
    }

    private var resources: TransferInputResources?

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        validationPresenter,
        ctaButtonPresenter
    ]

    override init() {
        let viewModel = dydxTransferOutViewModel()

        validationPresenter.$viewModel.assign(to: &viewModel.$validationViewModel)
        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButton)

        super.init()

        viewModel.amountBox?.stepSize = 0.01
        viewModel.amountBox?.onEdited = { [weak self] amount in
            var amountDouble = Parser.standard.asNumber(amount?.unlocalizedNumericValue)?.doubleValue ?? 0
            amountDouble = min(amountDouble, self?.viewModel?.amountBox?.maxAmount ?? 0)
            if self?.selectedToken?.type == dydxTokenConstants.usdcTokenKey {
                AbacusStateManager.shared.transfer(input: Parser.standard.asString(amountDouble), type: .usdcsize)
            } else if self?.selectedToken?.type == dydxTokenConstants.nativeTokenKey {
                AbacusStateManager.shared.transfer(input: Parser.standard.asString(amountDouble), type: .size)
            }
        }

        viewModel.$addressInput
            .debounce(for: .milliseconds(10), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { address in
                AbacusStateManager.shared.transfer(input: address, type: .address)
            })
            .store(in: &subscriptions)

        viewModel.memoBox.$text
            .debounce(for: .milliseconds(10), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { memo in
                AbacusStateManager.shared.transfer(input: memo, type: .memo)
            })
            .store(in: &subscriptions)

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.transferInput
            .map(\.type)
            .prefix(1)
            .sink { type in
                if type != .transferout {
                    AbacusStateManager.shared.transfer(input: nil, type: .address)
                    AbacusStateManager.shared.startTransferOut()
                }
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.transferInput
            .sink { [weak self] transferInput in
                self?.updateTransferInput(transferInput: transferInput)
            }
            .store(in: &subscriptions)

        Publishers.CombineLatest3(
            $selectedToken.removeDuplicates(),
            AbacusStateManager.shared.state.selectedSubaccount
                .map(\.?.freeCollateral?.current)
                .removeDuplicates(),
            AbacusStateManager.shared.state.accountBalance(of: AbacusStateManager.shared.environment?.nativeTokenInfo?.denom)
        )
            .sink { [weak self] selectedToken, freeCollateral, nativeTokenAmount in
                if selectedToken?.type == dydxTokenConstants.usdcTokenKey {
                    self?.viewModel?.amountBox?.maxAmount = freeCollateral?.doubleValue ?? 0
                    self?.viewModel?.amountBox?.tokenText = TokenTextViewModel(symbol: selectedToken?.localizedString ?? "")
                    self?.viewModel?.objectWillChange.send()
                } else if selectedToken?.type == dydxTokenConstants.nativeTokenKey {
                    self?.viewModel?.amountBox?.maxAmount = nativeTokenAmount ?? 0
                    self?.viewModel?.amountBox?.tokenText = TokenTextViewModel(symbol: selectedToken?.localizedString ?? "")
                    self?.viewModel?.objectWillChange.send()
                }
            }
            .store(in: &subscriptions)
    }

    private func updateTransferInput(transferInput: TransferInput) {
        let newChains = transferInput.transferOutOptions?.chains
        if chains != newChains {
            chains = newChains ?? [SelectionOption]()
            selectedChain = chains.first { $0.type == transferInput.chain }
        }
        let newTokens = transferInput.transferOutOptions?.assets
        if tokens != newTokens {
            tokens = newTokens ?? [SelectionOption]()
            selectedToken = tokens.first { $0.type == transferInput.token }
        }

        resources = transferInput.resources
        updateChainsTokensViewModel()

        let size: Double
        if selectedToken?.type == dydxTokenConstants.usdcTokenKey {
            size = parser.asDecimal(transferInput.size?.usdcSize)?.doubleValue ?? 0
        } else if selectedToken?.type == dydxTokenConstants.nativeTokenKey {
            size = parser.asDecimal(transferInput.size?.size)?.doubleValue ?? 0
        } else {
            size = 0
        }
        if size > 0 {
            viewModel?.amountBox?.value = dydxFormatter.shared.raw(number: NSNumber(value: size), size: "0.01")
        } else {
            viewModel?.amountBox?.value = nil
        }
        viewModel?.amountBox?.objectWillChange.send()

        viewModel?.addressInput = transferInput.address ?? ""

        viewModel?.memoBox.shouldDisplayWarningWhenEmpty = transferInput.token != dydxTokenConstants.usdcTokenKey
        viewModel?.memoBox.text = transferInput.memo ?? ""
    }

    private func updateChainsTokensViewModel() {
        if chains.count > 0 {
            let chainsComboBox = ChainsComboBoxModel()
            chainsComboBox.text = selectedChain?.localizedString
            if let iconUrl = selectedChain?.iconUrl, let url = URL(string: iconUrl) {
                chainsComboBox.icon = .init(type: .url(url: url), size: CGSize(width: 24, height: 24))
            }
            chainsComboBox.label = DataLocalizer.localize(path: "APP.GENERAL.NETWORK")
            if chains.count > 1 {
                chainsComboBox.onTapAction = { [weak self] in
                    PlatformView.hideKeyboard()
                    let params = dydxTransferSearchViewBuilder.createSearchRoutingRequest(options: self?.chains ?? [], selected: self?.selectedChain, resources: self?.resources, selectedCallback: { option in
                        if self?.selectedChain != option {
                            self?.selectedChain = option
                            AbacusStateManager.shared.transfer(input: option?.type, type: TransferInputField.chain)
                        }
                    })
                    Router.shared?.navigate(to: RoutingRequest(path: "/transfer/search", params: params), animated: true, completion: nil)
                }
            }
        }

        if tokens.count > 0 {
            let tokensComboBox = TokensComboBoxModel()
            tokensComboBox.label = DataLocalizer.localize(path: "APP.GENERAL.ASSET")
            if let iconUrl = selectedToken?.iconUrl, let url = URL(string: iconUrl) {
                tokensComboBox.icon = .init(type: .url(url: url), size: CGSize(width: 24, height: 24))
            }
            tokensComboBox.text = selectedToken?.localizedString
            if tokens.count > 1 {
                tokensComboBox.onTapAction = { [weak self] in
                    PlatformView.hideKeyboard()
                    let params = dydxTransferSearchViewBuilder.createSearchRoutingRequest(options: self?.tokens ?? [], selected: self?.selectedToken, resources: self?.resources, selectedCallback: { option in
                        if self?.selectedToken != option {
                            self?.selectedToken = option
                            AbacusStateManager.shared.transfer(input: option?.type, type: TransferInputField.token)
                        }
                    })
                    Router.shared?.navigate(to: RoutingRequest(path: "/transfer/search", params: params), animated: true, completion: nil)
                }
            }
            viewModel?.tokensComboBox = tokensComboBox
        }
    }
}
