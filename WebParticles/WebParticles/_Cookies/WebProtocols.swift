//
//  WebProtocols.swift
//  WebParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import WebKit

public protocol WebCookieProtocol: NSObject {
    var domain: String { get set }
    var path: String { get set }
    var isSecure: Bool { get set }
    var isSessionOnly: Bool { get set }
    var isHttpOnly: Bool { get set }
    var name: String { get set }
    var value: String? { get set }
    var expires: Date? { get set }
}

public typealias WebCookieCompletion = () -> Void
public typealias WebCookieGetCompletion = (_ cookies: [HTTPCookie]?) -> Void

public protocol WebCookieStorageProtocol: NSObjectProtocol {
    var domain: String { get set }
    func cookies(path: String, secure: Bool, completion: @escaping WebCookieGetCompletion)
    func set(cookie: WebCookieProtocol, completion: WebCookieCompletion?)
    func delete(cookie: WebCookieProtocol, completion: WebCookieCompletion?)
}

public protocol WebCookieDomainProtocol: NSObjectProtocol {
    var domain: String { get set }
    var cookieStorage: WebCookieStorageProtocol? { get set }
}
