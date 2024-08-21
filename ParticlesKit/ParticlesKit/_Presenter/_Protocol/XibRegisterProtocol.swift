//
//  QueuedXibListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public protocol XibRegisterProtocol: NSObjectProtocol {
    var registeredXibs: Set<String> { get set }
    func registerXibIfNeeded(_ xibFile: String?)
    func register(xib: String)
}

extension XibRegisterProtocol {
    public func registerXibIfNeeded(_ xibFile: String?) {
        if let xibFile = xibFile {
            if !registeredXibs.contains(xibFile) {
                registeredXibs.insert(xibFile)
                register(xib: xibFile)
            }
        }
    }
}
