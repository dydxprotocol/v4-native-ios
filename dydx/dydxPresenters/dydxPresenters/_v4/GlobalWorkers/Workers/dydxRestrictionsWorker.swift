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

        // used in protocol 4.0
        AbacusStateManager.shared.state.restriction
            .sink { restriction in
                Self.handle(restriction: restriction)
            }
            .store(in: &subscriptions)

        // used in protocol 5.0
        AbacusStateManager.shared.state.compliance
            .sink { compliance in
                Self.handle(compliance: compliance)
            }
            .store(in: &subscriptions)
    }

    public static func handle(compliance: Compliance) {
        let title: String?
        let body: String?
        switch compliance.status {
        case .compliant:
            return
        case .firstStrike, .firstStrikeCloseOnly, .closeOnly:
            title = DataLocalizer.shared?.localize(
                path: "APP.COMPLIANCE.CLOSE_ONLY_TITLE",
                params: nil) ?? ""
            body = DataLocalizer.shared?.localize(
                path: "APP.COMPLIANCE.CLOSE_ONLY_BODY",
                params: [
                    "DATE": compliance.expiresAt ?? "--",
                    "EMAIL": AbacusStateManager.shared.environment?.links?.complianceSupportEmail ?? "--"
                ]) ?? ""
        case .blocked:
            title = DataLocalizer.shared?.localize(
                path: "APP.COMPLIANCE.PERMANENTLY_BLOCKED_TITLE",
                params: nil) ?? ""
            body = DataLocalizer.shared?.localize(
                path: "APP.COMPLIANCE.PERMANENTLY_BLOCKED_BODY",
                params: [
                    "EMAIL": AbacusStateManager.shared.environment?.links?.complianceSupportEmail ?? "--"
                ]) ?? ""
        default:
            return
        }
        ErrorInfo.shared?.info(title: title, message: body, type: .error, error: nil, time: 30.0)
        AbacusStateManager.shared.disconnectAndReplaceCurrentWallet()
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
            ErrorInfo.shared?.info(title: title, message: body, type: .error, error: nil, time: 10.0)
        default:
            assertionFailure("unknown restriction error, please add support for restriction \(restriction)")
        }
    }
}
