//
//  AbacusState+Combine.swift
//  dydxStateManager
//
//  Created by Rui Huang on 9/29/22.
//

import Utilities
import Abacus
import Combine
import CombineExt
import dydxFormatter

public final class AbacusState {
    private let parser = Utilities.Parser()
    /**
     Onboarded
     **/
    public var onboarded: AnyPublisher<Bool, Never> {
        walletState
            .map { walletState in
                (walletState.currentWallet?.cosmoAddress?.length ?? 0) > 0
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Current wallet
     **/
    public var currentWallet: AnyPublisher<dydxWalletInstance?, Never> {
        walletState
            .map(\.currentWallet)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Transfers
     **/
    public var transfers: AnyPublisher<[SubaccountTransfer], Never> {
        statePublisher
            .map(\.?.transfers)
            .compactMap { [weak self] transfers in
                if let subaccountNumber = self?.subaccountNumber, let transfers = transfers?[subaccountNumber] {
                    return Array(transfers)
                }
                return []
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public func transferInstance(transactionHash: String?) -> AnyPublisher<dydxTransferInstance?, Never> {
        transferState
            .map { $0.transfers.first { $0.transactionHash == transactionHash } }
            .share()
            .eraseToAnyPublisher()
    }

    /**
     TransferStatuses (Abacus state of transfer statuses)
     **/
    public var transferStatuses: AnyPublisher<[String: TransferStatus]?, Never> {
        statePublisher
            .map(\.?.transferStatuses)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Account
     **/
    public var account: AnyPublisher<Account?, Never> {
        statePublisher
            .map(\.?.account)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var launchIncentive: AnyPublisher<LaunchIncentive?, Never> {
        statePublisher
            .map(\.?.launchIncentive)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var hasAccount: AnyPublisher<Bool, Never> {
        statePublisher
            .compactMap {
                $0?.account != nil
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /// protocol pre v5.0
    public var restriction: AnyPublisher<Restriction, Never> {
        statePublisher
            .compactMap { $0?.restriction?.restriction ?? .noRestriction }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    // protocol v5.0 and up
    public var compliance: AnyPublisher<Compliance, Never> {
        statePublisher
            .compactMap { $0?.compliance }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public func accountBalance(of tokenDenom: String?) -> AnyPublisher<Double?, Never> {
        account
            .map { account in
                self.parser.asDecimal(account?.balances?[tokenDenom ?? ""]?.amount)?.doubleValue
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public func stakingBalance(of tokenDenom: String?) -> AnyPublisher<Double?, Never> {
        account
            .map { account in
                self.parser.asDecimal(account?.stakingBalances?[tokenDenom ?? ""]?.amount)?.doubleValue
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Subaccount
     **/
    public func subaccount(of subaccountNumber: String) -> AnyPublisher<Subaccount?, Never> {
        account
            .compactMap(\.?.groupedSubaccounts?[subaccountNumber])
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var selectedSubaccount: AnyPublisher<Subaccount?, Never> {
        statePublisher
            .map { [weak self] (state: PerpetualState?) in
                if let key = self?.subaccountNumber, let subaccounts = state?.account?.groupedSubaccounts {
                    return subaccounts[key]
                }
                return nil
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var selectedSubaccountFills: AnyPublisher<[SubaccountFill], Never> {
        statePublisher
            .compactMap { [weak self] (state: PerpetualState?) in
                if let key = self?.subaccountNumber, let fill = state?.fills?[key] {
                    return Array(fill)
                }
                return []
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var selectedSubaccountFundings: AnyPublisher<[SubaccountFundingPayment], Never> {
        statePublisher
            .compactMap { [weak self] (state: PerpetualState?) in
                if let key = self?.subaccountNumber, let funding = state?.fundingPayments?[key] {
                    return Array(funding)
                }
                return []
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var selectedSubaccountPositions: AnyPublisher<[SubaccountPosition], Never> {
        selectedSubaccount
            .compactMap { subaccount in
                subaccount?.openPositions
            }
            .prepend([])
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public func selectedSubaccountPositionOfMarket(marketId: String) -> AnyPublisher<SubaccountPosition?, Never> {
        selectedSubaccountPositions
            .map { positions in
                positions.first { position in
                    position.id == marketId &&
                    (position.side.current == Abacus.PositionSide.long_ || position.side.current == Abacus.PositionSide.short_)
                }
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var selectedSubaccountPendingPositions: AnyPublisher<[SubaccountPendingPosition], Never> {
        selectedSubaccount
            .compactMap { subaccount in
                subaccount?.pendingPositions
            }
            .prepend([])
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var selectedSubaccountOrders: AnyPublisher<[SubaccountOrder], Never> {
        selectedSubaccount
            .compactMap { subaccount in
                subaccount?.orders
            }
            .prepend([])
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public func selectedSubaccountOrdersOfMarket(marketId: String) -> AnyPublisher<[SubaccountOrder], Never> {
        selectedSubaccountOrders
            .map { orders in
                orders.filter { $0.marketId == marketId }
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var selectedSubaccountTriggerOrders: AnyPublisher<[SubaccountOrder], Never> {
        selectedSubaccountOrders
            .map { orders in
                orders.filter { order in
                    order.status == .untriggered
                }
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public func takeProfitOrders(marketId: String, includeLimitOrders: Bool) -> AnyPublisher<[SubaccountOrder], Never> {
        Publishers
            .CombineLatest(
                selectedSubaccountPositionOfMarket(marketId: marketId),
                selectedSubaccountTriggerOrders
                )
            .compactMap { (position: SubaccountPosition?, orders: [SubaccountOrder]) in
                orders.filter { order in
                    guard let side = position?.side.current, order.marketId == marketId else { return false }
                    return (
                        order.type == OrderType.takeprofitmarket ||
                        (order.type == OrderType.takeprofitlimit && includeLimitOrders)
                    ) && order.side.opposite == side
                }
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public func stopLossOrders(marketId: String, includeLimitOrders: Bool) -> AnyPublisher<[SubaccountOrder], Never> {
        Publishers
            .CombineLatest(
                selectedSubaccountPositionOfMarket(marketId: marketId),
                selectedSubaccountTriggerOrders
                )
            .compactMap { (position: SubaccountPosition?, orders: [SubaccountOrder]) in
                orders.filter { order in
                    guard let side = position?.side.current, order.marketId == marketId else { return false }
                    return (
                        order.type == OrderType.stopmarket ||
                        (order.type == OrderType.stoplimit && includeLimitOrders)
                    ) && order.side.opposite == side
                }
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var selectedSubaccountPNLs: AnyPublisher<[SubaccountHistoricalPNL], Never> {
        statePublisher
            .compactMap { [weak self] (state: PerpetualState?) in
                if let key = self?.subaccountNumber, let pnls = state?.historicalPnl?[key] {
                    return Array(pnls)
                }
                return []
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Fundings
     **/
    public var historicalFundingsMap: AnyPublisher<[String: [MarketHistoricalFunding]], Never> {
        statePublisher
            .compactMap(\.?.historicalFundings)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Fundings of a given market
     **/
    public func historicalFundings(of marketId: String) -> AnyPublisher<[MarketHistoricalFunding]?, Never> {
        historicalFundingsMap
            .compactMap { $0[marketId] }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Market Summary
     **/
    public var marketSummary: AnyPublisher<PerpetualMarketSummary, Never> {
        statePublisher
            .compactMap(\.?.marketsSummary)
            .removeDuplicates()
            .throttle(for: .milliseconds(1000), scheduler: DispatchQueue.main, latest: true)
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Map from market ID to Candles
     **/
    public var candlesMap: AnyPublisher<[String: MarketCandles], Never> {
        statePublisher
            .compactMap(\.?.candles)
            .prepend([:])
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Candles of a given market
     **/
    public func candles(of marketId: String) -> AnyPublisher<MarketCandles?, Never> {
        candlesMap
            .compactMap { $0[marketId] }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Map from market ID to Orderbook
     **/
    public var orderbooksMap: AnyPublisher<[String: MarketOrderbook], Never> {
        statePublisher
            .compactMap(\.?.orderbooks)
            .prepend([:])
            .throttle(for: .milliseconds(10), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Orderbook of a given market
     **/
    public func orderbook(of marketId: String) -> AnyPublisher<MarketOrderbook?, Never> {
        orderbooksMap
            .compactMap { $0[marketId] }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Map from market ID to Trades
     **/
    public var tradesMap: AnyPublisher<[String: [MarketTrade]], Never> {
        statePublisher
            .compactMap(\.?.trades)
            .prepend([:])
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Trades of a given market
     **/
    public func trades(of marketId: String) -> AnyPublisher<[MarketTrade]?, Never> {
        tradesMap
            .compactMap { $0[marketId] }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     List of market IDs
     **/
    public var marketIds: AnyPublisher<[String], Never> {
        marketSummary
            .compactMap { $0.marketIds() }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Map from market ID to Market
     **/
    public var marketMap: AnyPublisher<[String: PerpetualMarket], Never> {
        marketSummary
            .compactMap(\.markets)
            .prepend([:])
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     List Market ordrered by market IDs
     **/
    public var marketList: AnyPublisher<[PerpetualMarket], Never> {
        Publishers
            .CombineLatest(marketIds,
                           marketMap)
            .compactMap { (ids: [String], map: [String: PerpetualMarket]) -> [PerpetualMarket] in
                ids.compactMap { id in
                    map[id]
                }
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Market of a given market ID
     **/
    public func market(of marketId: String) -> AnyPublisher<PerpetualMarket?, Never> {
        marketMap
            .compactMap { $0[marketId] }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Asset of given asset Id
     **/
    public var assetMap: AnyPublisher<[String: Asset], Never> {
        statePublisher
            .compactMap(\.?.assets)
            .throttle(for: .milliseconds(1000), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Asset of given asset Id
     **/
    public func asset(of assetId: String) -> AnyPublisher<Asset, Never> {
        assetMap
            .compactMap(\.[assetId])
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     MarketConfigs and Asset map
     **/
    public var configsAndAssetMap: AnyPublisher<[String: MarketConfigsAndAsset], Never> {
        Publishers
            .CombineLatest(
                marketMap,
                assetMap
            )
            .compactMap { (marketMap: [String: PerpetualMarket], assetMap: [String: Asset]) in
                var output = [String: MarketConfigsAndAsset]()
                for (marketId, market) in marketMap {
                    output[marketId] = MarketConfigsAndAsset(configs: market.configs, asset: assetMap[market.assetId], assetId: market.assetId)
                }
                return output
            }
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var tradeInput: AnyPublisher<TradeInput?, Never> {
        statePublisher
            .map(\.?.input?.trade)
            .throttle(for: .milliseconds(10), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var adjustIsolatedMarginInput: AnyPublisher<AdjustIsolatedMarginInput?, Never> {
        statePublisher
            .map(\.?.input?.adjustIsolatedMargin)
            .throttle(for: .milliseconds(10), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var triggerOrdersInput: AnyPublisher<TriggerOrdersInput?, Never> {
        statePublisher
            .map(\.?.input?.triggerOrders)
            .removeDuplicates()
            .throttle(for: .milliseconds(10), scheduler: DispatchQueue.main, latest: true)
            .share()
            .eraseToAnyPublisher()
    }

    public var closePositionInput: AnyPublisher<ClosePositionInput, Never> {
        statePublisher
            .compactMap(\.?.input?.closePosition)
            .throttle(for: .milliseconds(10), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Transfer input
     **/

    public var transferInput: AnyPublisher<TransferInput, Never> {
        statePublisher
            .compactMap(\.?.input?.transfer)
            .throttle(for: .milliseconds(10), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Input receipts
     **/

    public var receipts: AnyPublisher<[ReceiptLine], Never> {
        statePublisher
            .map { state in
                if let lines = state?.input?.receiptLines {
                    return lines
                }
                return []
            }
            .throttle(for: .milliseconds(10), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Input validation
      **/

    public var validationErrors: AnyPublisher<[ValidationError], Never> {
        statePublisher
            .map { state in
                if let errors = state?.input?.errors {
                    return Array(errors)
                }
                return []
            }
            .throttle(for: .milliseconds(10), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     Backend Error
      */
    public var backendError: AnyPublisher<ParsingError?, Never> {
        errorsStatePublisher
            .compactMap { (errors: [ParsingError]?) -> ParsingError? in
                errors?.first { error in
                    switch error.type {
                    case .backenderror:
                        return true
                    default:
                        return false
                    }
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /**
     Config
      */
    public var configs: AnyPublisher<Configs?, Never> {
        statePublisher
            .map(\.?.configs)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /**
     User
     **/
    public var user: AnyPublisher<User?, Never> {
        statePublisher
            .map(\.?.wallet?.user)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    public var vault: AnyPublisher<Vault?, Never> {
        statePublisher
            .map(\.?.vault)
            .removeDuplicates()
            .share()
            .eraseToAnyPublisher()
    }

    /**
     ApiState
      */
    public let environment: AnyPublisher<V4Environment?, Never>
    public let apiState: AnyPublisher<ApiState?, Never>
    public let walletState: AnyPublisher<dydxWalletState, Never>
    public let transferState: AnyPublisher<dydxTransferState, Never>
    public let lastOrder: AnyPublisher<SubaccountOrder?, Never>
    public let alerts: AnyPublisher<[Abacus.Notification], Never>

    private let statePublisher: AnyPublisher<PerpetualState?, Never>
    private let errorsStatePublisher: AnyPublisher<[ParsingError], Never>
    private let abacusStateManager: AsyncAbacusStateManagerProtocol & AsyncAbacusStateManagerSingletonProtocol

    private var subaccountNumber: String? {
        "\(abacusStateManager.subaccountNumber)"
    }

    init(walletStatePublisher: AnyPublisher<dydxWalletState, Never>,
         perpetualStatePublisher: AnyPublisher<PerpetualState?, Never>,
         environmentPublisher: AnyPublisher<V4Environment?, Never>,
         apiStatePublisher: AnyPublisher<ApiState?, Never>,
         errorsStatePublisher: AnyPublisher<[ParsingError], Never>,
         lastOrderPublisher: AnyPublisher<SubaccountOrder?, Never>,
         abacusStateManager: AsyncAbacusStateManagerProtocol & AsyncAbacusStateManagerSingletonProtocol,
         alertsPublisher: AnyPublisher<[Abacus.Notification], Never>,
         transferStatePublisher: AnyPublisher<dydxTransferState, Never>) {
        self.walletState = walletStatePublisher.removeDuplicates().share(replay: 1).eraseToAnyPublisher()
        self.statePublisher = perpetualStatePublisher.removeDuplicates().share(replay: 1).eraseToAnyPublisher()
        self.environment = environmentPublisher.removeDuplicates().share(replay: 1).eraseToAnyPublisher()
        self.apiState = apiStatePublisher.removeDuplicates().share(replay: 1).eraseToAnyPublisher()
        self.errorsStatePublisher = errorsStatePublisher.removeDuplicates().share(replay: 1).eraseToAnyPublisher()
        self.lastOrder = lastOrderPublisher.removeDuplicates().share(replay: 1).eraseToAnyPublisher()
        self.abacusStateManager = abacusStateManager
        self.alerts = alertsPublisher.removeDuplicates().share(replay: 1).eraseToAnyPublisher()
        self.transferState = transferStatePublisher.removeDuplicates().share(replay: 1).eraseToAnyPublisher()
    }
}

public struct MarketConfigsAndAsset: Equatable {
    public init(configs: MarketConfigs?, asset: Asset?, assetId: String) {
        self.configs = configs
        self.asset = asset
        self.assetId = assetId
    }

    public let configs: MarketConfigs?
    public let asset: Asset?
    public let assetId: String
}

public extension Array where Element: AnyObject {
    init(_ kotlinArray: KotlinArray<Element>?) {
        self.init()
        if let kotlinArray = kotlinArray {
            let iterator = kotlinArray.iterator()
            while iterator.hasNext() {
                if let element = iterator.next() as? Element {
                    append(element)
                }
            }
        }
    }

    var kotlinArray: KotlinArray<Element>? {
        KotlinArray(size: Int32(count)) { index in
            self[index.intValue]
        }
    }
}

public extension Date {
    init(milliseconds: Double) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

private extension PerpetualState {
    var firstSubaccountKey: String? {
        let n = Array(availableSubaccountNumbers)
        if let first = n.first {
            let key = "\(first.intValue)"
            return key
        }
        return nil
    }
}
