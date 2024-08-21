//
//  XibGridPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

open class XibGridPresenter: NativeGridPresenter, XibPresenterProtocol {
    public var xibCache: XibPresenterCache = XibPresenterCache()

    @IBInspectable public var xibMap: String? {
        didSet {
            xibCache.xibMap = xibMap
        }
    }

    public var xibRegister: XibRegisterProtocol?

    public func xib(object: ModelObjectProtocol?) -> String? {
        if let xibFile = xibCache.xib(object: object) {
            xibRegister?.registerXibIfNeeded(xibFile)
            return xibFile
        }
        return nil
    }
}
