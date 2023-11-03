//
//  dydxRestrictionsWorker.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 9/27/23.
//

import Abacus
import Combine
import dydxStateManager
import ParticlesKit
import RoutingKit
import Utilities

public final class dydxRestrictionsWorker: BaseWorker {

    public override func start() {
        super.start()

        AbacusStateManager.shared.state.restriction
            .compactMap { $0 }
            .removeDuplicates()
            .sink { restriction in
                Self.handle(restriction: restriction)
            }
            .store(in: &subscriptions)
    }

    public static func handle(restriction: Restriction) {
        switch restriction {
        case .geoRestricted:
            Router.shared?.navigate(to: RoutingRequest(path: "/error/geo"), animated: true, completion: nil)
        case .noRestriction:
            break
        case .userRestricted:
            let title = DataLocalizer.shared?.localize(path: "ERRORS.ONBOARDING.WALLET_RESTRICTED_ERROR_TITLE", params: nil) ?? ""
            let body = DataLocalizer.shared?.localize(path: "ERRORS.ONBOARDING.REGION_NOT_PERMITTED_SUBTITLE", params: nil) ?? ""
            ErrorInfo.shared?.info(title: title, message: body, type: .error, error: nil)
            AbacusStateManager.shared.disconnectAndReplaceCurrentWallet()
        case .userRestrictionUnknown:
            let title = DataLocalizer.shared?.localize(path: "ERRORS.GENERAL.RATE_LIMIT_REACHED_ERROR_TITLE", params: nil) ?? ""
            let body = DataLocalizer.shared?.localize(path: "ERRORS.GENERAL.RATE_LIMIT_REACHED_ERROR_MESSAGE", params: nil) ?? ""
            ErrorInfo.shared?.info(title: title, message: body, type: .error, error: nil)
        default:
            assertionFailure("unknown restriction error, please add support for restriction \(restriction)")
        }
    }
}
