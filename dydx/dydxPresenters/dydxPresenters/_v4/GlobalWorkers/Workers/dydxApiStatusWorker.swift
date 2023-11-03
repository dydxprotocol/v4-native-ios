//
//  dydxApiStatusWorker.swift
//  dydxPresenters
//
//  Created by Rui Huang on 2/15/23.
//

import Abacus
import Combine
import dydxStateManager
import Foundation
import ParticlesKit
import Utilities

final class dydxApiStatusWorker: BaseWorker {
    private var lastState: ApiState? {
        didSet {
            didSetLastState(oldValue: oldValue)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.apiState
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] apiState in
                self?.updateApiStatus(apiState: apiState)
            }
            .store(in: &subscriptions)
    }

    private func updateApiStatus(apiState: ApiState) {
        lastState = apiState
    }

    private func didSetLastState(oldValue: ApiState?) {
        if lastState?.status != oldValue?.status {
            guard let lastState = lastState, let status = lastState.status else {
                return
            }

            switch status {
            case .indexerDown:
                ErrorInfo.shared?.info(title: nil,
                                       message: DataLocalizer.localize(path: "APP.V4.INDEXER_DOWN"),
                                       type: .error,
                                       error: nil, time: nil, actions: [createDismissAction(status: status)])

            case .indexerHalted:
                if oldValue?.status != .indexerDown {
                    // No need to show if indexer is recovering from more serious error state, but not recovered yet
                    ErrorInfo.shared?.info(title: nil,
                                           message: DataLocalizer.localize(path: "APP.V4.INDEXER_HALTED",
                                                                           params: ["HALTED_BLOCK": "\(lastState.haltedBlock?.intValue ?? 0)"]),
                                           type: .warning,
                                           error: nil, time: nil, actions: [createDismissAction(status: status)])
                }

            case .indexerTrailing:
                if oldValue?.status != .indexerDown && oldValue?.status != .indexerHalted {
                    // No need to show if indexer is recovering from more serious error state, but not recovered yet
                    ErrorInfo.shared?.info(title: nil,
                                           message: DataLocalizer.localize(path: "APP.V4.INDEXER_TRAILING",
                                                                           params: ["TRAILING_BLOCKS": "\(lastState.trailingBlocks?.intValue ?? 0)"]),
                                           type: .warning,
                                           error: nil, time: nil, actions: [createDismissAction(status: status)])
                }

            case .validatorDown:
                ErrorInfo.shared?.info(title: nil,
                                       message: DataLocalizer.localize(path: "APP.V4.VALIDATOR_DOWN"),
                                       type: .error,
                                       error: nil, time: nil, actions: [createDismissAction(status: status)])

            case .validatorHalted:
                if oldValue?.status != .validatorDown {
                    // No need to show if validator is recovering from more serious error state, but not recovered yet
                    ErrorInfo.shared?.info(title: nil,
                                           message: DataLocalizer.localize(path: "APP.V4.VALIDATOR_HALTED",
                                                                           params: ["HALTED_BLOCK": "\(lastState.haltedBlock?.intValue ?? 0)"]),
                                           type: .warning,
                                           error: nil, time: nil, actions: [createDismissAction(status: status)])
                }

            case .normal:
                if oldValue?.status != .normal && oldValue?.status != .unknown && oldValue?.status != nil {
                    ErrorInfo.shared?.info(title: nil,
                                           message: DataLocalizer.localize(path: "APP.V4.NETWORK_RECOVERED"),
                                           type: .info,
                                           error: nil, time: 3.0, actions: nil)
                }
            case .unknown:
                break
            default:
                break
            }
        }
    }

    private func createDismissAction(status: ApiStatus) -> Utilities.ErrorAction {
        ErrorAction(text: DataLocalizer.localize(path: "APP.GENERAL.DISMISS")) {
        }
    }
}
