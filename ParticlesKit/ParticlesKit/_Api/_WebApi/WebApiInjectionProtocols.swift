//
//  WebApiRequestInjectionProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 5/15/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol WebApiRequestInjectionProtocol: NSObjectProtocol {
    func inject(request: URLRequest, verb: HttpVerb, completion: @escaping (_ request: URLRequest) -> Void)
    func cookies(completion: @escaping ([String: String]?) -> Void)
}

public protocol WebApiResponseInjectionProtocol: NSObjectProtocol {
    func inject(response: URLResponse?, data: Any?, verb: HttpVerb?)
}
