//
//  URL+Params.swift
//  Utilities
//
//  Created by Qiang Huang on 10/18/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

extension URL {
    public var params: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }

        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }

        return parameters
    }
}
