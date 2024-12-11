//
//  dydxTransferDepositViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 4/7/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Abacus
import dydxStateManager
import dydxCartera
import Combine
import Web3
import BigInt
import dydxFormatter

protocol dydxTransferDepositViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxTransferDepositViewModel? { get }
}

class dydxTransferDepositViewPresenter: HostedViewPresenter<dydxTransferDepositViewModel>, dydxTransferDepositViewPresenterProtocol {
    private var ethereumInteractor: EthereumInteractor?
    private let validationPresenter = dydxValidationViewPresenter(receiptType: .transfer)
    private let ctaButtonPresenter = dydxTransferInputCtaButtonViewPresenter(transferType: .deposit)

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
        let viewModel = dydxTransferDepositViewModel()

        validationPresenter.$viewModel.assign(to: &viewModel.$validationViewModel)
        ctaButtonPresenter.$viewModel.assign(to: &viewModel.$ctaButton)

        super.init()

        viewModel.amountBox?.stepSize = 0.001
        viewModel.amountBox?.onEdited = { [weak self] amount in
            var amountDouble = Parser.standard.asNumber(amount?.unlocalizedNumericValue)?.doubleValue ?? 0
            amountDouble = min(amountDouble, self?.viewModel?.amountBox?.maxAmount ?? 0)
            if amountDouble != self?.currentSize {
                AbacusStateManager.shared.transfer(input: Parser.standard.asString(amountDouble), type: .size)
            }
         }

        viewModel.connectWalletAction = {
            let request = RoutingRequest(path: "/onboard/wallets",
                                         params: ["mobileOnly": "true"])
            Router.shared?.navigate(to: request, animated: true, completion: nil)
        }

        self.viewModel = viewModel

        attachChildren(workers: childPresenters)
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.transferInput
            .map(\.type)
            .prefix(1)
            .sink { type in
                if type != .deposit {
                    AbacusStateManager.shared.startDeposit()
                }
            }
            .store(in: &subscriptions)

        AbacusStateManager.shared.state.transferInput
            .sink { [weak self] transferInput in
                self?.updateTransferInput(transferInput: transferInput)
            }
            .store(in: &subscriptions)

        Publishers
            .CombineLatest4(
                AbacusStateManager.shared.state.transferInput
                    .map(\.resources)
                    .removeDuplicates(),
                AbacusStateManager.shared.state.transferInput
                    .map(\.chain)
                    .removeDuplicates(),
                AbacusStateManager.shared.state.transferInput
                    .map(\.token)
                    .removeDuplicates(),
                AbacusStateManager.shared.state.currentWallet
                    .map(\.?.ethereumAddress)
                    .removeDuplicates()
            ).sink { [weak self] (resources: TransferInputResources?, chain: String?, tokenAddress: String?, ethereumAddress: String?) in
                if let tokenAddress = tokenAddress,
                   let walletAddress = ethereumAddress,
                   walletAddress.starts(with: "dydx") == false,
                   let chain = chain,
                   let chainRpc = resources?.chainResources?[chain]?.rpc,
                   let tokenResource = resources?.tokenResources?[tokenAddress],
                   let tokenSymbol = tokenResource.symbol,
                   let tokenDecimals = tokenResource.decimals {
                    self?.viewModel?.showConnectWallet = false
                    self?.fetchTokenAmount(chainRpc: chainRpc, tokenSymbol: tokenSymbol, tokenAddress: tokenAddress, tokenDecimals: tokenDecimals.intValue, walletAddress: walletAddress)
                } else {
                    self?.viewModel?.showConnectWallet = true
                    self?.ethereumInteractor = nil
                }
            }
            .store(in: &subscriptions)
    }

    private func fetchTokenAmount(chainRpc: String, tokenSymbol: String, tokenAddress: String, tokenDecimals: Int, walletAddress: String) {
        guard let address = try? EthereumAddress(hex: walletAddress, eip55: false) else {
            Console.shared.log("Invalid wallet address")
            return
        }

        ethereumInteractor = EthereumInteractor(url: chainRpc)
        updateMaxAmount(tokenSymbol: tokenSymbol, amount: nil)
        if tokenAddress == "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" {
            ethereumInteractor?.eth_getBalance(address: address) { [weak self, ethereumInteractor] result in
                guard ethereumInteractor === self?.ethereumInteractor else { return }
                switch result.status {
                case .success(let amount):
                    let string = "\(amount.quantity)"
                    let balance = EthConversions.uint256ToHumanTokenString(output: string, decimals: tokenDecimals)
                    self?.updateMaxAmount(tokenSymbol: tokenSymbol, amount: Parser.standard.asNumber(balance)?.doubleValue)
                case .failure(let error):
                    Console.shared.log("Failed to get balance: \(error)")
                    self?.updateMaxAmount(tokenSymbol: tokenSymbol, amount: nil)
                }
            }
        } else {
            guard let contract = try? EthereumAddress(hex: tokenAddress, eip55: false) else {
                Console.shared.log("Invalid token address")
                return
            }
            let function = ERC20BalanceOfFunction(contract: contract, from: address, account: address)
            if let transaction = try? function.call() {
                ethereumInteractor?.eth_call(transaction) { [weak self, ethereumInteractor] result in
                    guard ethereumInteractor === self?.ethereumInteractor else { return }
                    switch result.status {
                    case .success(let data):
                        if let amount = self?.parser.asUInt256(data.ethereumValue().string) {
                            let string = "\(amount)"
                            let balance = EthConversions.uint256ToHumanTokenString(output: string, decimals: tokenDecimals)
                            self?.updateMaxAmount(tokenSymbol: tokenSymbol, amount: Parser.standard.asNumber(balance)?.doubleValue)
                        } else {
                            Console.shared.log("Unable to parse response amount")
                            self?.updateMaxAmount(tokenSymbol: tokenSymbol, amount: nil)
                        }
                    case .failure(let error):
                        Console.shared.log("Failed to get balance: \(error)")
                        self?.updateMaxAmount(tokenSymbol: tokenSymbol, amount: nil)
                    }
                }
            }
        }
    }

    private func updateMaxAmount(tokenSymbol: String, amount: Double?) {
        viewModel?.amountBox?.maxAmount = amount
        viewModel?.amountBox?.tokenText = TokenTextViewModel(symbol: tokenSymbol)
        viewModel?.objectWillChange.send()
    }

    private func updateTransferInput(transferInput: TransferInput) {
        let newChains = transferInput.depositOptions?.chains
        if chains != newChains {
            chains = newChains ?? [SelectionOption]()
            selectedChain = chains.first { $0.type == transferInput.chain }
        }
        let newTokens = transferInput.depositOptions?.assets
        if tokens != newTokens {
            tokens = newTokens ?? [SelectionOption]()
            selectedToken = tokens.first { $0.type == transferInput.token }
        }

        resources = transferInput.resources
        updateChainsTokensViewModel()

        let size: Double = parser.asNumber(transferInput.size?.size)?.doubleValue ?? 0
        if size > 0 {
            viewModel?.amountBox?.value = dydxFormatter.shared.raw(number: NSNumber(value: size), size: "0.001")
        } else {
            viewModel?.amountBox?.value = nil
        }
        viewModel?.amountBox?.objectWillChange.send()

        currentSize = size
    }

    private func updateChainsTokensViewModel() {
        if chains.count > 0 {
            let chainsComboBox = ChainsComboBoxModel()
            chainsComboBox.text = selectedChain?.localizedString
            if let iconUrl = selectedChain?.iconUrl, let url = URL(string: iconUrl), UIDevice.current.isSimulator == false {
                chainsComboBox.icon = .init(type: .url(url: url), size: CGSize(width: 24, height: 24))
            }
            chainsComboBox.label = DataLocalizer.localize(path: "APP.GENERAL.SOURCE")
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
            tokensComboBox.label = DataLocalizer.localize(path: "APP.GENERAL.ASSET")
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
