//
//  UrlBadgingInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import RoutingKit

@objc public class UrlBadgingInteractor: DictionaryInteractor, UrlBadgingProtocol {
    @objc public func badge(url: String, value: String?) {
        set(value, for: url)
    }

    @objc public func badge(for url: String) -> String? {
        return value(forKey: url) as? String
    }
}
