//
//  AbacusTrackingImp.swift
//  dydxStateManager
//
//  Created by John Huang on 7/17/23.
//

import Foundation
import Abacus
import Utilities

final public class AbacusTrackingImp: NSObject, Abacus.TrackingProtocol {
    public func log(event: String, data: String?) {
        let jsonDictionary = data?.jsonDictionary ?? [:]
        self.log(event: event, data: jsonDictionary)
    }

    public func log(event: String, data: [String: Any]) {
        Tracking.shared?.log(event: event, data: data)
    }
}
