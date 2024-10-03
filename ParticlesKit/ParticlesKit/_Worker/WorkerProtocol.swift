//
//  WorkerProtocol.swift
//  ParticlesKit
//
//  Created by Rui Huang on 8/2/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation
import Combine

public protocol WorkerProtocol: NSObjectProtocol {
    func start()
    func stop()
    var isStarted: Bool { get set }
}

open class BaseWorker: NSObject, WorkerProtocol {
    public var subscriptions = Set<AnyCancellable>()
    public var isStarted = false

    public override init() {}

    open func start() {
        if !isStarted {
            isStarted = true
        }
    }

    open func stop() {
        if isStarted {
            subscriptions.forEach { cancellable in
                cancellable.cancel()
            }
            subscriptions.removeAll()
            isStarted = false
        }
    }
}
