//
//  TransferRouteSelection.swift
//  dydxPresenters
//
//  Created by Rui Huang on 27/02/2025.
//

import Foundation
import Combine
import dydxViews

final class TransferRouteSelectionInfo {
    @Published var allSelections: [TransferRouteSelection] = []
    @Published var selected: TransferRouteSelection?

    static var shared: TransferRouteSelectionInfo = TransferRouteSelectionInfo()
}
