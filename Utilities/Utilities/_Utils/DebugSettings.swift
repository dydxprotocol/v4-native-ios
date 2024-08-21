//
//  DebugSettings.swift
//  Utilities
//
//  Created by Qiang Huang on 11/30/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol DebugProtocol {
    var debug: [String: Any]? { get set }
}

public class DebugSettings {
    public static var shared: DebugProtocol?
}

public extension DebugProtocol {
    func customized() -> Bool {
        #if DEBUG
            return false
        #else
            return (debug?.count ?? 0) > 0
        #endif
    }
}
