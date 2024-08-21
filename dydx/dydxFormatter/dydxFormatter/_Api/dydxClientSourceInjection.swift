//
//  dydxClientSourceInjection.swift
//  dydxModels
//
//  Created by John Huang on 4/27/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import ParticlesKit
import Utilities

public class dydxClientSourceInjection: NSObject, WebApiRequestInjectionProtocol {
    public func inject(request: URLRequest, verb: HttpVerb, completion: @escaping (_ request: URLRequest) -> Void) {
        var request = request
        var headers: [String: String] = request.allHTTPHeaderFields ?? [:]
        headers["client"] = "01"

        request.allHTTPHeaderFields = headers
        completion(request)
    }

    public func cookies(completion: @escaping ([String: String]?) -> Void) {
        completion(nil)
    }
}
