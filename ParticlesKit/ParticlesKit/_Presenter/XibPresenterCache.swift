//
//  XibPresenterCache.swift
//  ParticlesKit
//
//  Created by John Huang on 1/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

open class XibPresenterCache: NSObject {
    private static var sharedXibMapFile: XibJsonFile = {
        XibJsonFile(fileName: ParticilesKitConfig.xibJson, bundles: Bundle.particles)
    }()

    private var xibMapFile: XibJsonFile?

    private var xibCache: [String: String] = [:]
    public var xibSizes: [String: CGSize] = [:]
    public var xibMap: String? {
        didSet {
            if xibMap != oldValue {
                if let xibMap = xibMap {
                    xibMapFile = XibJsonFile(fileName: xibMap, bundles: Bundle.particles)
                }
            }
        }
    }

    public func xibFile(object: ModelObjectProtocol?) -> String? {
        if let object = object {
            var xib: String?
            if let xibProvider = object as? XibProviderProtocol {
                xib = xibProvider.xib
            }
            let className = (object as? NSObject)?.className()
            if xib == nil, let className = className {
                xib = xibCache[className]
            }
            if xib == nil {
                if let xibFile = xibMapFile {
                    xib = xibFile.xibFile(object: object)
                    if let xib = xib, let className = className {
                        xibCache[className] = xib
                    }
                }
            }
            if xib == nil {
                let xibFile = XibPresenterCache.sharedXibMapFile
                xib = xibFile.xibFile(object: object)
                if let xib = xib, let className = className {
                    xibCache[className] = xib
                }
            }
            if xib == nil {
                let className = String(describing: type(of: object))
                Console.shared.log("XIB not found for \(className)")
            }
            return xib
        }
        return nil
    }

    public func xib(object: ModelObjectProtocol?) -> String? {
        if let xibFile = self.xibFile(object: object) {
            return xibFile
        }
        return nil
    }

    public func defaultSize(xib: String?) -> CGSize? {
        if let xib = xib {
            var size = xibSizes[xib]
            if size == nil {
                if let loadedView: UIView = XibLoader.load(from: xib) {
                    size = loadedView.frame.size
                    xibSizes[xib] = size
                }
            }
            return size
        }
        return nil
    }
}
