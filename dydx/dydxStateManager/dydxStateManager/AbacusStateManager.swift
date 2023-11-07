//
//  AbacusStateManager.swift
//  abacus.ios
//
//  Created by John Huang on 9/12/22.
//

import Abacus
import Combine
import Utilities
import ParticlesKit

public final class AbacusStateManager: NSObject {
    public static let shared = AbacusStateManager()

    public let deploymentUri = (CredientialConfig.shared.key(for: "webAppUrl"))!

    public var isMainNet: Bool {
        asyncStateManager.environment?.isMainNet ?? false
    }

    public var ethereumChainId: Int {
        parser.asInt(asyncStateManager.environment?.ethereumChainId) ?? 5
    }

    public var dydxChainId: String? {
        asyncStateManager.environment?.dydxChainId
    }

    public var environment: V4Environment? {
        asyncStateManager.environment
    }

    public var appSetting: AppSetting? {
        asyncStateManager.appSettings?.ios
    }

    public lazy var state: AbacusState = {
        let perpetualStatePublisher =
            $_perpetualState
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        let alertsPublisher =
            $_alerts
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        let environmentPublisher =
            $_environment
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        let apiStatePublisher =
            $_apiState
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        let errorsStatePublisher =
            $_errors
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        let lastOrderPublisher =
            $_lastOrder
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        let walletStatePublisher =
            $_walletState
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        let transferStatePublisher =
            transferStateManager.$state
                .compactMap { $0 }
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        return AbacusState(walletStatePublisher: walletStatePublisher,
                           perpetualStatePublisher: perpetualStatePublisher,
                           environmentPublisher: environmentPublisher,
                           apiStatePublisher: apiStatePublisher,
                           errorsStatePublisher: errorsStatePublisher,
                           lastOrderPublisher: lastOrderPublisher,
                           abacusStateManager: asyncStateManager,
                           alertsPublisher: alertsPublisher,
                           transferStatePublisher: transferStatePublisher)
    }()

    @Published private var _perpetualState: PerpetualState?
    @Published private var _apiState: ApiState?
    @Published private var _environment: V4Environment?
    @Published private var _alerts = [Abacus.Notification]()
    @Published private var _errors: [ParsingError] = []
    @Published private var _lastOrder: SubaccountOrder?

    @Published private var _walletState = dydxWalletState()

    @Published public var currentEnvironment: String? {
        didSet {
            if currentEnvironment != oldValue {
                SettingsStore.shared?.setValue(currentEnvironment, forKey: Self.storeKey)
                if asyncStateManager.environmentId != currentEnvironment {
                    asyncStateManager.readyToConnect = false
                    asyncStateManager.environmentId = currentEnvironment
                }
                start()
            }
        }
    }

    private let transferStateManager = dydxTransferStateManager.shared
    private lazy var foregroundToken: NotificationToken = {
        NotificationCenter.default.observe(notification: UIApplication.willEnterForegroundNotification) { [weak self] _ in
            if self?.isStarted ?? false {
                self?.asyncStateManager.readyToConnect = true
            }
        }
    }()

    private lazy var backgroundToken: NotificationToken = {
        NotificationCenter.default.observe(notification: UIApplication.didEnterBackgroundNotification) { [weak self] _ in
            if self?.isStarted ?? false {
                self?.asyncStateManager.readyToConnect = false
            }
        }
    }()

    private let startDebouncer = Debouncer()

    private var isStarted = false

    private lazy var asyncStateManager = {
        UIImplementations.reset(language: nil)

        let deployment: String
        let appConfigs: AppConfigs
        if DebugEnabled.enabled {
            // For debugging only
            deployment = "DEV"
            #if DEBUG
            appConfigs = AppConfigs.companion.forAppDebug
            #else
            appConfigs = AppConfigs.companion.forApp
            #endif
        } else {
            // Expose more options for Testflight build
            deployment = Installation.appStore ? "MAINNET" : "TESTNET"
            appConfigs = AppConfigs.companion.forApp
        }

        return AsyncAbacusStateManager(
            deploymentUri: deploymentUri + "/",
            deployment: deployment,
            appConfigs: appConfigs,
            ioImplementations: IOImplementations.shared,
            uiImplementations: UIImplementations.shared!,
            stateNotification: self,
            dataNotification: nil
        )
    }()

    override private init() {
        super.init()

        _ = CosmoJavascript.shared
        _ = foregroundToken
        _ = backgroundToken

//        Abacus.ProtocolNativeImpFactory.companion.setStateNotification(stateNotification: self)
    }

    private func start() {
        let handler = startDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.reallyStart()
        }, delay: 0.01)
    }

    private func reallyStart() {
        if let ethereumAddress = _walletState.currentWallet?.ethereumAddress,
           let cosmoAddress = _walletState.currentWallet?.cosmoAddress,
           let mnemonic = _walletState.currentWallet?.mnemonic {
            let walletId = _walletState.currentWallet?.walletId
            setV4(ethereumAddress: ethereumAddress, walletId: walletId, cosmoAddress: cosmoAddress, mnemonic: mnemonic)
        }

        if let ethereumAddress = _walletState.currentWallet?.ethereumAddress,
           let apiKey = _walletState.currentWallet?.apiKey,
           let passPhrase = _walletState.currentWallet?.passPhrase,
           let secret = _walletState.currentWallet?.secret {
            let walletId = _walletState.currentWallet?.walletId
            setV3(ethereumAddress: ethereumAddress, walletId: walletId, apiKey: apiKey, secret: secret, passPhrase: passPhrase)
        }
        asyncStateManager.readyToConnect = true
        isStarted = true
    }

    public func setMarket(market: String?) {
        asyncStateManager.market = market
    }

    public func setV3(ethereumAddress: String, walletId: String?, apiKey: String, secret: String, passPhrase: String) {
        let wallet = dydxWalletInstance.V3(ethereumAddress: ethereumAddress, walletId: walletId, apiKey: apiKey, secret: secret, passPhrase: passPhrase)
        _walletState.setCurrentWallet(wallet: wallet)
        asyncStateManager.accountAddress = ethereumAddress
    }

    public func setV4(ethereumAddress: String, walletId: String?, cosmoAddress: String, mnemonic: String) {
        CosmoJavascript.shared.connectWallet(mnemonic: mnemonic) { [weak self] _ in
            if let self = self {
                let wallet = dydxWalletInstance.V4(ethereumAddress: ethereumAddress, walletId: walletId, cosmoAddress: cosmoAddress, mnemonic: mnemonic)
                self._walletState.setCurrentWallet(wallet: wallet)
                self.asyncStateManager.accountAddress = cosmoAddress
                self.asyncStateManager.sourceAddress = ethereumAddress
            }
        }
    }

    /// disconnects the current wallet and any associated state. Resets the necessary fields to the next available wallet.
    public func disconnectAndReplaceCurrentWallet() {
        _walletState.disconnectAndReplaceCurrentWallet()

        if _walletState.wallets.isEmpty {
            transferStateManager.clear()
        }

        asyncStateManager.accountAddress = _walletState.currentWallet?.ethereumAddress
    }

    public func setCandlesResolution(candlesResolution: String) {
        asyncStateManager.candlesResolution = candlesResolution
    }

    public func setHistoricalPNLPeriod(period: HistoricalPnlPeriod) {
        asyncStateManager.historicalPnlPeriod = period
    }

    public func startTrade() {
        asyncStateManager.trade(data: nil, type: nil)
    }

    public func startTransfer() {
        asyncStateManager.transfer(data: nil, type: nil)
    }

    public func startClosePosition(marketId: String) {
        asyncStateManager.closePosition(data: marketId, type: ClosePositionInputField.market)
    }

    public func startDeposit() {
        asyncStateManager.transfer(data: "DEPOSIT", type: .type)
    }

    public func startWithdrawal() {
        asyncStateManager.transfer(data: "WITHDRAWAL", type: .type)
    }

    public func startTransferOut() {
        asyncStateManager.transfer(data: "TRANSFER_OUT", type: .type)
    }

    public func trade(input: String?, type: TradeInputField?) {
        asyncStateManager.trade(data: input, type: type)
    }

    public func closePosition(input: String?, type: ClosePositionInputField) {
        asyncStateManager.closePosition(data: input, type: type)
    }

    public func transfer(input: String?, type: TransferInputField?) {
        asyncStateManager.transfer(data: input, type: type)
    }

    public func screen(address: String, callback: @escaping (Restriction) -> Void) {
        asyncStateManager.screen(address: address, callback: callback)
    }

    /// batch parallel address screening
    /// - Parameters:
    ///   - addresses: the addresses to scan
    ///   - callback: returns tuples of addres-restriction pairs
    public func screen(addresses: [String], callback: @escaping ([(address: String, restriction: Restriction)]) -> Void) {
        let group = DispatchGroup()
            var results: [(String, Restriction)] = []
            let lock = DispatchQueue(label: "com.yourapp.resultsLock.\(UUID().uuidString)") // to synchronize results array

            for address in addresses {
                group.enter()

                screen(address: address) { restriction in
                    lock.async {
                        results.append((address, restriction))
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                callback(results)
            }
    }

    public func faucet(amount: Int32) {
        asyncStateManager.faucet(amount: Double(amount)) { [weak self] successful, _, _ in
            if !successful.boolValue {
            }
        }
    }

    public func setOrderbookMultiplier(multiplier: OrderbookGrouping) {
        asyncStateManager.orderbookGrouping = multiplier
    }

    public var availableEnvironments: [SelectionOption] {
        asyncStateManager.availableEnvironments
    }

    private func initializeCurrentEnvironment() {
        if currentEnvironment == nil,
           let stored = SettingsStore.shared?.value(forKey: Self.storeKey) as? String,
            availableEnvironments.contains(where: { selection in
                selection.type == stored
            }) {
            currentEnvironment = stored
        } else {
            currentEnvironment = asyncStateManager.environment?.id
        }
    }

    public func addTransferInstance(transfer: dydxTransferInstance) {
        transferStateManager.add(transfer: transfer)
    }

    public func removeTransferInstance(transfer: dydxTransferInstance) {
        transferStateManager.remove(transfer: transfer)
    }

    public func transferStatus(hash: String, fromChainId: String?, toChainId: String?) {
        asyncStateManager.transferStatus(hash: hash, fromChainId: fromChainId, toChainId: toChainId)
    }

    private static let storeKey = "AbacusStateManager.EnvState"
}

extension AbacusStateManager: Abacus.StateNotificationProtocol {
    public func environmentsChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.initializeCurrentEnvironment()
        }
    }

    public func notificationsChanged(notifications: [Abacus.Notification]) {
        _alerts = notifications
    }

    public func apiStateChanged(apiState: ApiState?) {
        _apiState = apiState
    }

    public func stateChanged(state: PerpetualState?, changes: StateChanges?) {
        _perpetualState = state
    }

    public func lastOrderChanged(order: SubaccountOrder?) {
        _lastOrder = order
    }

    public func errorsEmitted(errors: [ParsingError]) {
        _errors = errors
    }
}

extension AbacusStateManager {
    public enum SubmissionStatus {
        case success
        case failed(Abacus.ParsingError?)
    }

    public func placeOrder(callback: @escaping ((SubmissionStatus) -> Void)) {
        asyncStateManager.commitPlaceOrder { successful, error, _ in
            if successful.boolValue {
                callback(.success)
            } else {
                callback(.failed(error))
            }
        }
    }

    public func closePosition(callback: @escaping ((SubmissionStatus) -> Void)) {
        asyncStateManager.commitClosePosition { successful, error, _ in
            if successful.boolValue {
                callback(.success)
            } else {
                callback(.failed(error))
            }
        }
    }

    public func transfer() {
        asyncStateManager.commitTransfer { [weak self] successful, _, _ in
            if successful.boolValue {
                // TODO: Dismiss
            } else {
                // TODO: Show error
            }
        }
    }

    public func cancelOrder(orderId: String, callback: @escaping ((SubmissionStatus) -> Void)) {
        asyncStateManager.cancelOrder(orderId: orderId) { successful, error, _ in
            if successful.boolValue {
                callback(.success)
            } else {
                callback(.failed(error))
            }
        }
    }
}
