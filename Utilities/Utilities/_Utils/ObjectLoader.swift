//
//  ObjectLoader.swift
//  Utilities
//
//  Created by Rui Huang on 8/12/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation

public struct ObjectLoader {
    public static func load<T: NSObject>(from xibOrClassName: String, completion: @escaping ((T?) -> Void)) {
        if let xibLoaded: T = XibLoader.load(from: xibOrClassName) {
            completion(xibLoaded)
        } else {
            ClassLoader.load(from: xibOrClassName, completion: completion)
        } 
    }
}
