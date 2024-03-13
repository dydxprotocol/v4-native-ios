//
//  dydxTransferState.swift
//  dydxStateManager
//
//  Created by Rui Huang on 4/20/23.
//

import Foundation
import Utilities

public final class dydxTransferStateManager: SingletonProtocol {
    public static var shared = dydxTransferStateManager()

    @Published var state: dydxTransferState?

    private static let storeKey = "AbacusStateManager.TransferState"

    init() {
        state = dydxClientState.load(storeKey: Self.storeKey) ?? dydxTransferState()
    }

    public func add(transfer: dydxTransferInstance) {
        if state?.transfers.contains(transfer) == false {
            state?.transfers.append(transfer)
            dydxClientState.store(state: state, storeKey: Self.storeKey)
        }
    }

    public func remove(transfer: dydxTransferInstance) {
        if let index = state?.transfers.firstIndex(of: transfer) {
            state?.transfers.remove(at: index)
            dydxClientState.store(state: state, storeKey: Self.storeKey)
        }
    }

    public func clear() {
        state?.transfers = []
        dydxClientState.store(state: state, storeKey: Self.storeKey)
    }
}

public struct dydxTransferState: Codable, Equatable {
    public var transfers: [dydxTransferInstance] = []
}

public struct dydxTransferInstance: Codable, Equatable {
    public enum TransferType: String, Codable {
        case deposit, withdrawal, transferOut
    }

    public let transferType: TransferType
    public let transactionHash: String
    public let fromChainId: String?
    public let fromChainName: String?
    public let toChainId: String?
    public let toChainName: String?
    public let date: Date
    public let usdcSize: Double?
    public let size: Double?
    public let isCctp: Bool?
    public let requestId: String?

    public init(transferType: dydxTransferInstance.TransferType, transactionHash: String, fromChainId: String?, fromChainName: String?, toChainId: String?, toChainName: String?, date: Date, usdcSize: Double?, size: Double?, isCctp: Bool?, requestId: String?) {
        self.transferType = transferType
        self.transactionHash = transactionHash
        self.fromChainId = fromChainId
        self.fromChainName = fromChainName
        self.toChainId = toChainId
        self.toChainName = toChainName
        self.date = date
        self.usdcSize = usdcSize
        self.size = size
        self.isCctp = isCctp
        self.requestId = requestId
    }
}
