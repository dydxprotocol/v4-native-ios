//
//  WebApiRequestHeaderInjection.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 8/8/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

public class WebApiRequestHeaderInjection: NSObject, WebApiRequestInjectionProtocol {
    var headers: [String: String]?
    public init(headers: [String: String]?) {
        super.init()
        self.headers = headers
    }

    public func inject(request: URLRequest, verb: HttpVerb, completion: @escaping (_ request: URLRequest) -> Void) {
        if let headers = headers {
            var request = request
            var httpHeaders: [String: String] = request.allHTTPHeaderFields ?? [:]
            for (key, value) in headers {
                httpHeaders[key] = value
            }
            request.allHTTPHeaderFields = httpHeaders
            completion(request)
        } else {
            completion(request)
        }
    }

    public func cookies(completion: @escaping ([String: String]?) -> Void) {
        completion(nil)
    }
}
