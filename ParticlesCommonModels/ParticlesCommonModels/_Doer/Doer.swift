//
//  Doer.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/2/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

public protocol DoerProtocol {
    func perform() -> Bool
    func undo()
}

public final class Doer: NSObject, SingletonProtocol {
    private var doers: [DoerProtocol] = [DoerProtocol]()

    public static var shared: Doer = {
        Doer()
    }()

    public func perform(_ doer: DoerProtocol) -> Bool {
        if doer.perform() {
            doers.append(doer)
            return true
        } else {
            return false
        }
    }

    public func undo() {
        if let doer = doers.last {
            doer.undo()
            doers.removeLast()
        }
    }
}
