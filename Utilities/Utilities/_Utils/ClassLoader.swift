//
//  ClassLoader.swift
//  Utilities
//
//  Created by Rui Huang on 8/12/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation

public protocol ObjectBuilderProtocol: NSObjectProtocol {
    func build<T>() -> T?
    func buildAsync<T>(completion: @escaping ((T?) -> Void))
}

public extension ObjectBuilderProtocol {
    func buildAsync<T>(completion: @escaping ((T?) -> Void)) {
        completion(nil)
    }
}

public struct ClassLoader {
    private static var cache: [String: AnyClass] = [:]

    public static func load<T>(from className: String, completion: @escaping ((T?) -> Void)) {
        if let objClass = cache[className] as? NSObject.Type {
            let obj = objClass.init()
            if let ret = obj as? T {
                completion(ret)
                return
            }
            if let builder = obj as? ObjectBuilderProtocol {
                builder.buildAsync { (ret: T?) in
                    if ret != nil {
                         completion(ret)
                    } else if let ret: T = builder.build() {
                        completion(ret)
                    } else {
                        completion(nil)
                    }
                }
                return
            }
        }

        let bundles = Bundle.particles
        for bundle in bundles {
            // The builder objects are loaded dynamically so they need to NSObject
            // However, we can load the builder ObjC object, but builds a non-ObjC object
            if let objClass = bundle.classNamed(className) as? NSObject.Type {
                let obj = objClass.init()
                if let ret = obj as? T {
                    cache[className] = objClass
                    completion(ret)
                    return
                }
                if let builder = obj as? ObjectBuilderProtocol {
                    builder.buildAsync { (ret: T?) in
                        if ret != nil {
                            cache[className] = objClass
                            completion(ret)
                        } else if let ret: T = builder.build() {
                            cache[className] = objClass
                            completion(ret)
                        } else {
                            completion(nil)
                        }
                    }
                    return
                }
            }
        }

        // assertionFailure("ClassLoader: No matching object found for " + className)
        completion(nil)
    }
}
