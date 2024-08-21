//
//  BadgingProtocol.swift
//  RoutingKit
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc public protocol UrlBadgingProtocol: NSObjectProtocol {
    @objc func badge(url: String, value: String?)
    @objc func badge(for url: String) -> String?
}

public class UrlBadgingProvider: NSObject {
    public static var shared: UrlBadgingProtocol?
}
