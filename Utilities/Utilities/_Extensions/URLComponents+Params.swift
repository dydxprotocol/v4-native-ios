//
//  URLComponents+Params.swift
//  Utilities
//
//  Created by Qiang Huang on 5/11/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public extension URLComponents {
    var params: [String: String] {
        var params = [String: String]()
        if let queryItems = queryItems {
            for item in queryItems {
                params[item.name] = item.value
            }
        }
        return params
    }
}
