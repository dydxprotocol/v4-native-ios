//
//  dydxTransferWithdrawalViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 5/15/23.
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

protocol dydxTransferWithdrawalViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferWithdrawalViewModel? { get }
}

class dydxTransferWithdrawalViewPresenter: HostedViewPresenter<dydxTransferWithdrawalViewModel>, dydxTransferWithdrawalViewPresenterProtocol {
    private let validationPresenter = dydxValidationViewPresenter(receiptType: .transfer)
    private let ctaButtonPresenter = dydxTransferInputCtaButtonViewPresenter(transferType: .withdrawal)

    private lazy var childPresenters: [HostedViewPresenterProtocol] = [
        validationPresenter,
        ctaButtonPresenter
    ]

    private var chains: [SelectionOption] = []
    private var tokens: [SelectionOption] = []
    private var selectedChain: SelectionOption? {
        didSet {
            if selectedChain != oldValue {
                updateChainsTokensViewModel()
            }
        }
    }
    private var selectedToken: SelectionOption? {
        didSet {
            if selectedToken != oldValue {
                updateChainsTokensViewModel()
            }
        }
    }
    private var resources: TransferInputResources?

    private var currentSize: Double?

    override init() {
        let viewModel = dydxTransferWithdrawalViewModel()

        validationPresenter.$viewModel.assign(to: &viewModel.$validationViewModel)
        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButton)

        super.init()

        viewModel.amountBox?.stepSize = 0.01
        viewModel.amountBox?.onEdited = { [weak self] amount in
            var amountDouble = Parser.standard.asNumber(amount?.unlocalizedNumericValue)?.doubleValue ?? 0
            amountDouble = min(amountDouble, self?.viewModel?.amountBox?.maxAmount ?? 0)
            if amountDouble != self?.currentSize {
                AbacusStateManager.shared.transfer(input: Parser.standard.asString(amountDouble), type: .usdcsize)
            }
        }

        viewModel.addressInput?.onEdited = { address in
            AbacusStateManager.shared.transfer(input: address, type: .address)
        }

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.transferInput
                .map(\.type)
                .prefix(1),
            AbacusStateManager.shared.state.currentWallet
                .prefix(1)
        )
            .sink { type, wallet in
                if type != .withdrawal {
                    AbacusStateManager.shared.startWithdrawal()
                    if let ethereumAddress = wallet?.ethereumAddress {
                        // Default to user's eth address
                        AbacusStateManager.shared.transfer(input: ethereumAddress, type: .address)
                    }
                    AbacusStateManager.shared.transfer(input: wallet?.ethereumAddress, type: .address)
                }
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.transferInput
            .sink { [weak self] transferInput in
                self?.updateTransferInput(transferInput: transferInput)
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.selectedSubaccount
            .map(\.?.freeCollateral?.current)
            .removeDuplicates()
            .sink { [weak self] freeCollateral in
                self?.viewModel?.amountBox?.maxAmount = freeCollateral?.doubleValue ?? 0
                self?.viewModel?.amountBox?.tokenText = TokenTextViewModel(symbol: dydxTokenConstants.usdcTokenName)
                self?.viewModel?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }

    private func updateTransferInput(transferInput: TransferInput) {
        let newChains = transferInput.withdrawalOptions?.chains
        if chains != newChains {
            chains = newChains ?? [SelectionOption]()
            selectedChain = chains.first { $0.type == transferInput.chain }
        }
        let newTokens = transferInput.withdrawalOptions?.assets
        if tokens != newTokens {
            tokens = newTokens ?? [SelectionOption]()
            selectedToken = tokens.first { $0.type == transferInput.token }
        }

        resources = transferInput.resources
        updateChainsTokensViewModel()

        let size: Double = parser.asNumber(transferInput.size?.usdcSize)?.doubleValue ?? 0
        if size > 0 {
            viewModel?.amountBox?.value = dydxFormatter.shared.raw(number: NSNumber(value: size), size: "0.01")
        } else {
            viewModel?.amountBox?.value = nil
        }
        viewModel?.amountBox?.objectWillChange.send()

        currentSize = size

        viewModel?.addressInput?.value = transferInput.address
    }

    private func updateChainsTokensViewModel() {
        if chains.count > 0 {
            let chainsComboBox = ChainsComboBoxModel()
            chainsComboBox.text = selectedChain?.localizedString
            if let iconUrl = selectedChain?.iconUrl, let url = URL(string: iconUrl), UIDevice.current.isSimulator == false {
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
            viewModel?.chainsComboBox = chainsComboBox
        }

        if tokens.count > 0 {
            let tokensComboBox = TokensComboBoxModel()
            tokensComboBox.text = selectedToken?.localizedString
            if let iconUrl = selectedToken?.iconUrl, let url = URL(string: iconUrl), UIDevice.current.isSimulator == false {
                tokensComboBox.icon = .init(type: .url(url: url), size: CGSize(width: 24, height: 24))
            }
            tokensComboBox.label = DataLocalizer.localize(path: "APP.GENERAL.RECEIVE")
            if let tokenAddress = selectedToken?.type,
               let resource = resources?.tokenResources?[tokenAddress] {
                if let symbol = resource.symbol {
                    tokensComboBox.tokenText = TokenTextViewModel(symbol: symbol)
                }
            }
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
