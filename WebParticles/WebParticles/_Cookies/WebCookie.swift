//
//  WebCookie.swift
//  WebParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Utilities
import WebKit

public class WebCookie: NSObject, WebCookieProtocol {
    public var domain: String
    public var path: String
    public var isSecure: Bool = true
    public var isSessionOnly: Bool = false
    public var isHttpOnly: Bool = false
    public var name: String
    public var value: String?
    public var expires: Date?

    public init(domain: String, path: String = "/", isSecure: Bool = true, isSessionOnly: Bool = false, isHttpOnly: Bool = false, name: String, value: String?, expires: Date?) {
        self.domain = domain
        self.path = path
        self.isSecure = isSecure
        self.isSessionOnly = isSessionOnly
        self.isHttpOnly = isHttpOnly
        self.name = name
        self.value = value
        self.expires = expires
        super.init()
    }
}
