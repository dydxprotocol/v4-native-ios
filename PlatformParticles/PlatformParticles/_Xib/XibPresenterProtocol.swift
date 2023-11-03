//
//  XibPresenterProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 1/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

public protocol XibPresenterProtocol: NSObjectProtocol {
    var xibCache: XibPresenterCache { get set }
    func xib(object: ModelObjectProtocol?) -> String?
    func defaultSize(xib: String?) -> CGSize?
}

public extension XibPresenterProtocol {
    func xib(object: ModelObjectProtocol?) -> String? {
        return xibCache.xib(object: object)
    }

    func defaultSize(xib: String?) -> CGSize? {
        return xibCache.defaultSize(xib: xib)
    }
}
