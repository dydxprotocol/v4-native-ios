//
//  Mock.swift
//  dydxStateManager
//
//  Created by Michael Maguire on 10/1/24.
//

import Abacus

// can use when staging is down
public enum AbacusMockData {
    public static var vault: Abacus.Vault {
        .init(details: vaultDetails,
              positions: vaultPositions,
              account: vaultAccount)
    }
    
    public static var vaultDetails: VaultDetails {
        .init(totalValue: KotlinDouble(value: 230.234), thirtyDayReturnPercent: KotlinDouble(value: 230.234), history: [])
    }
    
    public static var vaultPositions: VaultPositions {
        .init(positions: [vaultPosition])
    }
    
    public static var vaultAccount: VaultAccount {
        .init(balanceUsdc: KotlinDouble(value: 230.234),
              balanceShares: KotlinDouble(value: 230.234),
              lockedShares: KotlinDouble(value: 230.234),
              withdrawableUsdc: KotlinDouble(value: 230.234),
              allTimeReturnUsdc: KotlinDouble(value: 230.234),
              vaultTransfers: [],
              totalVaultTransfersCount: KotlinInt(value: 230),
              vaultShareUnlocks: [])
    }
    
    public static var vaultPosition: VaultPosition {
        return VaultPosition.init(marketId: "1",
                                  marginUsdc: KotlinDouble(value: 230.234),
                                  equityUsdc: KotlinDouble(value: 230.234),
                                  currentLeverageMultiple: KotlinDouble(value: 230.234),
                                  currentPosition: CurrentPosition(asset: KotlinDouble(value: 230.234), usdc: KotlinDouble(value: 230.234)),
                                  thirtyDayPnl: ThirtyDayPnl(percent: KotlinDouble(value: 230.234), absolute: KotlinDouble(value: 230.234), sparklinePoints: [ KotlinDouble(value: 23.234), KotlinDouble(value: 0.234), KotlinDouble(value: 230.234)])
        )
    }
    
    public static var subaccount: Abacus.Subaccount {
        .init(subaccountNumber: Int32(0),
              positionId: "0",
              pnlTotal: KotlinDouble(value: 230.234),
              pnl24h: KotlinDouble(value: 230.234),
              pnl24hPercent: KotlinDouble(value: 230.234),
              quoteBalance: AbacusMockData.tradeStates,
              notionalTotal: AbacusMockData.tradeStates,
              valueTotal: AbacusMockData.tradeStates,
              initialRiskTotal: AbacusMockData.tradeStates,
              adjustedImf: AbacusMockData.tradeStates,
              equity: AbacusMockData.tradeStates,
              freeCollateral: AbacusMockData.tradeStates,
              leverage: AbacusMockData.tradeStates,
              marginUsage: AbacusMockData.tradeStates,
              buyingPower: AbacusMockData.tradeStates,
              openPositions: [AbacusMockData.subaccountPosition],
              pendingPositions: [],
              orders: [],
              marginEnabled: true)
    }
    
    public static var tradeStates: TradeStatesWithDoubleValues {
        .init(current: KotlinDouble(value: 230.234), postOrder: KotlinDouble(value: 230.234), postAllOrders: KotlinDouble(value: 230.234))
    }
    
    public static var tradeStatesWithStringValues: TradeStatesWithStringValues {
        .init(current: "230.234", postOrder: "230.234", postAllOrders: "230.234")
    }
    
    public static var subaccountPosition: SubaccountPosition {
        return SubaccountPosition.init(id: "1",
                                       assetId: "1",
                                       displayId: "1",
                                       side: TradeStatesWithPositionSides(current: PositionSide.long_, postOrder: PositionSide.long_, postAllOrders: PositionSide.long_),
                                       entryPrice: tradeStates,
                                       exitPrice: KotlinDouble(value: 230.234),
                                       createdAtMilliseconds: KotlinDouble(value: 230.234),
                                       closedAtMilliseconds: KotlinDouble(value: 230.234),
                                       netFunding: KotlinDouble(value: 230.234),
                                       realizedPnl: tradeStates,
                                       realizedPnlPercent: tradeStates,
                                       unrealizedPnl: tradeStates,
                                       unrealizedPnlPercent: tradeStates,
                                       size: tradeStates,
                                       notionalTotal: tradeStates,
                                       valueTotal: tradeStates,
                                       initialRiskTotal: tradeStates,
                                       adjustedImf: tradeStates,
                                       adjustedMmf: tradeStates,
                                       leverage: tradeStates,
                                       maxLeverage: tradeStates,
                                       buyingPower: tradeStates,
                                       liquidationPrice: tradeStates,
                                       resources: SubaccountPositionResources(sideString: tradeStatesWithStringValues, sideStringKey: tradeStatesWithStringValues, indicator: tradeStatesWithStringValues),
                                       childSubaccountNumber: KotlinInt(value: 230),
                                       freeCollateral: tradeStates,
                                       marginUsage: tradeStates,
                                       quoteBalance: tradeStates,
                                       equity: tradeStates,
                                       marginMode: MarginMode.cross,
                                       marginValue: tradeStates)
    }
                          
}
