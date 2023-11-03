//
//  RoutingRequest.swift
//  RoutingKit
//
//  Created by Qiang Huang on 10/11/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

@objc public class RoutingRequest: NSObject {
    public let originalUrl: String?
    public var scheme: String?
    public var host: String?
    public var path: String?
    public var params: [String: Any]?

    public var presentation: RoutingPresentation?

    public var url: URL? {
        if let originalUrl = originalUrl, let url = URL(string: originalUrl) {
            return url
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path ?? "/"
        if let params = params, params.count > 0 {
            urlComponents.queryItems = params.compactMap({ (arg0) -> URLQueryItem? in
                let (key, value) = arg0
                return URLQueryItem(name: key, value: parser.asString(value))
            })
        }
        return urlComponents.url
    }
    
    /// use this initializer to piecewise create a routing request
    public init(originalUrl: String? = nil, scheme: String? = nil, host: String? = nil, path: String, params: [String: Any]? = nil) {
        self.originalUrl = originalUrl
        self.scheme = scheme
        self.host = host
        self.path = path
        self.params = params
        super.init()
    }
    
    /// use this initializer to initialize a router request given a url
    public init(url: String?) {
        originalUrl = url
        // Swift does not handle "#" symbol mid-path so we need to manually clean.
        // e.g. https://v4.testnet.dydx.exchange/#/trade/AVAX-USD would parse the path as "/"
        // We hold onto original url in case we need to recover the #
        if let url = url, let urlComponents = URLComponents(string: url.replacingOccurrences(of: "/#/", with: "/")) {
            scheme = urlComponents.scheme
            host = urlComponents.host?.trim()
            path = urlComponents.path.trim()
            params = urlComponents.params
        }
        super.init()
    }

    public func modify(path: String) -> RoutingRequest? {
        return RoutingRequest(scheme: scheme, host: host, path: path, params: params)
    }
}
