//
//  ParamsHelper.swift
//  abacus.ios
//
//  Created by John Huang on 8/30/22.
//

import Abacus
import Foundation

public class ParamsHelper {
    static func map(params: [NetworkParam]?) -> [String: Any]? {
        if let params = params {
            var map = [String: Any]()
            for param in params {
                map[param.key] = param.value
            }
            return map
        } else {
            return nil
        }
    }
}
