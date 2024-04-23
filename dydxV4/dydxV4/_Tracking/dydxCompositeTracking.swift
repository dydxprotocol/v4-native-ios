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

enum UserProperty: String {
    case walletAddress
    case walletType
    case network
    case selectedLocale
    case dydxAddress
    case subaccountNumber
}

extension TrackingProtocol {
    fileprivate func set(userId: String?) {
        self.set(userProperty: .walletAddress, toValue: userId)
    }
    
    func set(userProperty: UserProperty, toValue value: String?) {
        self.setUserInfo(key: userProperty.rawValue, value: value)
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
                self.set(userId: walletState?.ethereumAddress ?? walletState?.cosmoAddress)
                //TODO: might have to change this to match https://www.notion.so/dydx/V4-Web-Analytics-Events-d12c9dd791ee4c5d89e48588bb3ef702?pvs=4, but first this linear task needs to finish https://linear.app/dydx/issue/TRCL-2473/create-wallettype-user-property-field-value-in-cartera-wallets-json
                self.set(userProperty: .walletType, toValue: wallet?.userFields?["analyticEvent"])
                self.set(userProperty: .dydxAddress, toValue: walletState?.cosmoAddress)
            }
            .store(in: &subscriptions)
        
        AbacusStateManager.shared.state.selectedSubaccount
            .map(\.?.subaccountNumber)
            .removeDuplicates()
            .sink { [weak self] subaccountNumber in
                guard let self = self else { return }
                self.set(userProperty: .subaccountNumber, toValue: self.parser.asString(subaccountNumber))
            }
            .store(in: &subscriptions)
    }
    
    private func setUpCurrentEnvironmentObserver() {
        AbacusStateManager.shared.$currentEnvironment
            .sink { [weak self] environment in
                guard let self = self else { return }
                self.set(userProperty: .network, toValue: environment)
            }
            .store(in: &subscriptions)
    }


    

    override public func view(_ path: String?, action: String?, data: [String: Any]?, from: String?, time: Date?, revenue: NSNumber?, contextViewController: UIViewController?) {
        if let transformed = transform(events: viewEvents, path: path), let event = parser.asString(transformed["event"]) {
            super.view(path, action: action, data: data, from: from, time: time, revenue: nil, contextViewController: contextViewController)
            let info = parser.asDictionary(transformed["info"]) ?? data ?? [String: Any]()
            log(event: event, data: info, revenue: revenue)
        } else {
            super.view(path, action: action, data: data, from: from, time: time, revenue: revenue, contextViewController: contextViewController)
        }
        if let contextViewController {
            
            log(event: AnalyticsEventScreenView,
                data: [
                    AnalyticsParameterScreenName: path as Any,
                    AnalyticsParameterScreenClass: String(describing: type(of: contextViewController))
                ])
        }
        if let transformed = transform(events: onboardingEvents, path: path), let event = parser.asString(transformed["event"]) {
            var info = parser.asDictionary(transformed["info"]) ?? data ?? [String: Any]()
            if event == "OnboardingStepChanged" {
                if let time = time, let previous = transform(events: onboardingEvents, path: from), parser.asString(transformed["event"]) == "OnboardingStepChanged" {
                    let seconds = Int(Date().timeIntervalSince(time))
                    info["secondsOnPreviousStep"] = NSNumber(value: seconds)
                    info["previousStep"] = (previous["info"] as? [String: Any])?["currentStep"]
                }
            }
            log(event: event, data: info, revenue: revenue)
        }
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
