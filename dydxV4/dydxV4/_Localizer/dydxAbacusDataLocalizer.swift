//
//  dydxAbacusDataLocalizer.swift
//  dydxV4
//
//  Created by Rui Huang on 5/4/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Abacus
import dydxStateManager
import Foundation
import ParticlesKit
import Utilities
import Combine

public class dydxAbacusDataLocalizer: DataLocalizerProtocol, AbacusLocalizerProtocol {

    public var languages: [SelectionOption] {
        get {
            (UIImplementations.shared?.localizer as? DynamicLocalizer)?.languages ?? []
        }
    }

    public var languagePublisher: AnyPublisher<String?, Never> {
        $language.eraseToAnyPublisher()
    }

    private var keyValueStore: KeyValueStoreProtocol?
    private let _languageTag = "language"

    @Published public var language: String? = (UIImplementations.shared?.localizer as? DynamicLocalizer)?.language

    public init(keyValueStore: KeyValueStoreProtocol?) {
        self.keyValueStore = keyValueStore

        let language = keyValueStore?.value(forKey: _languageTag) as? String
        UIImplementations.reset(language: language)
        if let language = language {
            setLanguage(language: language) { _ in
            }
        }
    }

    public func setLanguage(language: String, completed: @escaping (Bool) -> Void) {
        setLanguage(language: language) { successful, _ in
            completed(successful.boolValue)
        }
    }

    public func setLanguage(language: String, callback: @escaping (KotlinBoolean, ParsingError?) -> Void) {
        if let code = language.components(separatedBy: "-").first {
            (UIImplementations.shared?.localizer as? DynamicLocalizer)?.setLanguage(language: code, callback: { [weak self] successful, error in
                self?.language = (UIImplementations.shared?.localizer as? DynamicLocalizer)?.language
                if successful.boolValue {
                    if let self = self {
                        self.keyValueStore?.setValue(code, forKey: self._languageTag)
                    }
                }
                callback(successful, error)
            })
        } else {
            callback(false, nil)
        }
    }

    private func json(params: [String: String]?) -> String? {
        if let params = params {
            if let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                return String(data: data, encoding: String.Encoding.utf8)
            }
        }
        return nil
    }

    public func localize(path: String, params: [String: String]?) -> String? {
        return localize(path: path, paramsAsJson: json(params: params))
    }

    public func localize(path: String, paramsAsJson: String?) -> String {
        UIImplementations.shared?.localizer?.localize(path: path, paramsAsJson: paramsAsJson) ?? path
    }
}
