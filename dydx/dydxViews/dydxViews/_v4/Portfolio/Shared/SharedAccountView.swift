//
//  SharedAccountView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/13/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class SharedAccountViewModel: PlatformViewModel {
    @Published public var buyingPower: String?
    @Published public var marginUsage: String?
    @Published public var marginUsageIcon: MarginUsageModel?
    @Published public var equity: String?
    @Published public var freeCollateral: String?
    @Published public var openInterest: String?
    @Published public var leverage: String?
    @Published public var leverageIcon: LeverageRiskModel?

    public init() { }

    public static var previewValue: SharedAccountViewModel {
        let vm = SharedAccountViewModel()
        vm.buyingPower = "$22,222.12"
        vm.marginUsage = "4.55%"
        vm.marginUsageIcon = .previewValue
        vm.equity = "$22,222.12"
        vm.freeCollateral = "$22,222.12"
        vm.openInterest = "$22,222.12"
        vm.leverage = "0.12x"
        vm.leverageIcon = .previewValue
        return vm
    }
}
