//
//  AuthService.swift
//  Utilities
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

public final class AuthService: NSObject, SingletonProtocol {
    public static var shared: AuthService = AuthService()

    private var providers: [AuthProviderProtocol]?
    public var name: String? {
        didSet {
            didSetName(oldValue: oldValue)
        }
    }

    @objc public dynamic var provider: AuthProviderProtocol?
    
    public func didSetName(oldValue: String?) {
        if name != oldValue {
            updateProvider()
        }
    }

    public func add(provider: AuthProviderProtocol) {
        if providers == nil {
            providers = [AuthProviderProtocol]()
        }
        providers?.append(provider)
        updateProvider()
    }

    private func updateProvider() {
        provider = provider(named: name)
    }

    private func provider(named: String?) -> AuthProviderProtocol? {
        if let named = named {
            return providers?.first(where: { (provider) -> Bool in
                provider.name == named
            })
        } else {
            return providers?.first
        }
    }
}
