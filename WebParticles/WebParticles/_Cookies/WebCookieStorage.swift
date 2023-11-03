//
//  WebCookieStorage.swift
//  WebParticles
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import WebKit

public class WebCookieStorage: NSObject, WebCookieStorageProtocol {
    public var domain: String
    public var storage: WKHTTPCookieStore

    public init(configuration: WKWebViewConfiguration, domain: String) {
        self.domain = domain
        storage = configuration.websiteDataStore.httpCookieStore
        super.init()
    }

    public func cookies(path: String, secure: Bool, completion: @escaping WebCookieGetCompletion) {
        storage.getAllCookies { cookies in
            completion(cookies)
        }
    }

    public func set(cookie: WebCookieProtocol, completion: WebCookieCompletion?) {
        var properties = [HTTPCookiePropertyKey: Any]()
        properties[.domain] = cookie.domain
        properties[.path] = cookie.path
        properties[.secure] = cookie.isSecure
        properties[.name] = cookie.name
        if let value = cookie.value {
            properties[.value] = value
        }
        if let expires = cookie.expires {
            properties[.expires] = expires
        }
        if let cookie = HTTPCookie(properties: properties) {
            storage.setCookie(cookie) {
                completion?()
            }
        }
    }

    public func delete(cookie: WebCookieProtocol, completion: WebCookieCompletion?) {
    }
}
