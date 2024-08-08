//
//  dydxCompositeTracking.swift
//  dydxPlatformParticles
//
//  Created by John Huang on 4/25/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import ParticlesKit
import Utilities
import dydxStateManager
import Combine
import Cartera
import FirebaseAnalytics
import dydxAnalytics
import StatsigInjections
import dydxFormatter

extension TrackingProtocol {
    func setUserProperty(_ value: Any?, forUserProperty userProperty: UserProperty) {
        self.setUserProperty(value, forName: userProperty.rawValue)
    }
}

public class dydxCompositeTracking: CompositeTracking {
    private var viewEvents: DictionaryEntity?
    private var onboardingEvents: DictionaryEntity?

    private var subscriptions = Set<AnyCancellable>()
    
    override public init() {
        super.init()

        setUpCurrentWalletObserver()
        setUpCurrentEnvironmentObserver()
        
        if let destinations = (JsonLoader.load(bundle: Bundle.main, fileName: "dydxevents.json") ?? JsonLoader.load(bundles: Bundle.particles, fileName: "dydxevents.json")) as? [String: Any] {
            viewEvents = DictionaryEntity()
            viewEvents?.parse(dictionary: destinations)
        }
        if let destinations = (JsonLoader.load(bundle: Bundle.main, fileName: "onboardingevents.json") ?? JsonLoader.load(bundles: Bundle.particles, fileName: "onboardingevents.json")) as? [String: Any] {
            onboardingEvents = DictionaryEntity()
            onboardingEvents?.parse(dictionary: destinations)
        }
    }
    
    private func setUpCurrentWalletObserver() {
        AbacusStateManager.shared.state.currentWallet
            .sink { [weak self] walletState in
                guard let self = self else { return }
                let wallet = CarteraConfig.shared.wallets.first { $0.id == walletState?.walletId }
                let walletAddress = walletState?.ethereumAddress ?? walletState?.cosmoAddress
                self.setUserId(walletAddress)
                self.setUserProperty(walletAddress, forUserProperty: .walletAddress)
                //TODO: might have to change this to match https://www.notion.so/dydx/V4-Web-Analytics-Events-d12c9dd791ee4c5d89e48588bb3ef702?pvs=4, but first this linear task needs to finish https://linear.app/dydx/issue/TRCL-2473/create-wallettype-user-property-field-value-in-cartera-wallets-json
                self.setUserProperty(wallet?.userFields?["analyticEvent"], forUserProperty: .walletType)
                self.setUserProperty(walletState?.cosmoAddress, forUserProperty: .dydxAddress)
            }
            .store(in: &subscriptions)
        
        AbacusStateManager.shared.state.selectedSubaccount
            .map(\.?.subaccountNumber)
            .removeDuplicates()
            .sink { [weak self] subaccountNumber in
                guard let self = self else { return }
                self.setUserProperty(subaccountNumber, forUserProperty: .subaccountNumber)
            }
            .store(in: &subscriptions)
        
        // set user property for feature flags once statsig sdk is initialized.
        // Note, this will almost always, if not always, be `initializedRemoteLoading` since `initializedRemoteLoaded` requires round trip
        StatsigFeatureFlagsProvider.shared?.$initializationState
            .filter {
                switch $0 {
                case .initializedRemoteLoaded:
                    return true
                case .initializedRemoteLoading:
                    return true
                case .uninitialized:
                    return false
                }
            }
        // only need first since feature flags remain constant throughout session after first access.
        // See `sessionValues` in StatsigFeatureFlagsProvider
            .first()
            .sink { [weak self] _ in
                self?.setUserProperty(dydxBoolFeatureFlag.remoteState, forUserProperty: .statsigFlags)
                Console.shared.log("analytics log | dydxCompositeTracking: User Property feature flags initialized to \(dydxBoolFeatureFlag.remoteState)")
            }
            .store(in: &subscriptions)
    }
    
    private func setUpCurrentEnvironmentObserver() {
        AbacusStateManager.shared.$currentEnvironment
            .sink { [weak self] environment in
                guard let self = self else { return }
                self.setUserProperty(environment, forUserProperty: .network)
            }
            .store(in: &subscriptions)
    }

    override public func leave(_ path: String?) {
        super.leave(path)
        if let transformed = transform(events: viewEvents, path: path), let event = parser.asString(transformed["event"]) {
            let info = parser.asDictionary(transformed["info"])
            if let leavingEvent = leaving(event: event) {
                log(event: leavingEvent, data: info)
            }
        }
    }

    public func leaving(event: String) -> String? {
        switch event {
        case "NavigateDialog":
            return "NavigateDialogClose"

        default:
            return nil
        }
    }

    open func transform(events: DictionaryEntity?, path: String?) -> [String: Any]? {
        if let path = path {
            return (events?.data?[path] as? [String: Any])
        } else {
            return nil
        }
    }

    override open func log(event: String, data: [String: Any]?, revenue: NSNumber?) {
        let data = modify(data: data)
        super.log(event: event, data: data, revenue: revenue)
    }

    private func modify(data: [String: Any]?) -> [String: Any]? {
        return data
    }

    private func merge(_ data1: [String: Any]?, _ data2: [String: Any]?) -> [String: Any]? {
        if let data1 = data1 {
            if let data2 = data2 {
                return data1.merging(data2) { _, value2 in
                    value2
                }
            } else {
                return data1
            }
        } else {
            return data2
        }
    }
}
