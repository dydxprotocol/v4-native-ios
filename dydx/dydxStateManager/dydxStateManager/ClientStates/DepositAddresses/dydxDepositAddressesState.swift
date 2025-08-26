//
//  dydxDepositAddressesState.swift
//  dydxStateManager
//
//  Created by Rui Huang on 27/08/2025.
//

import Foundation
import Utilities

public final class dydxDepositAddressesStateManager: SingletonProtocol {
    public static var shared = dydxDepositAddressesStateManager()

    @Published public var state: DepositAddresses? {
        didSet {
            if state != oldValue, let state = state {
                dydxClientState.store(state: state, storeKey: Self.storeKey)
            }
        }
    }

    private static let storeKey = "AbacusStateManager.DepositAddresses"

    init() {
        state = dydxClientState.load(storeKey: Self.storeKey)
    }

    public func clear() {
         dydxClientState.store(state: DepositAddresses(), storeKey: Self.storeKey)
    }
}

public struct DepositAddresses: Codable, Equatable {
    public let evmAddress: String?
    public let avalancheAddress: String?
    public let svmAddress: String?

    public init(evmAddress: String? = nil, avalancheAddress: String? = nil, svmAddress: String? = nil) {
        self.evmAddress = evmAddress
        self.avalancheAddress = avalancheAddress
        self.svmAddress = svmAddress
    }
}
