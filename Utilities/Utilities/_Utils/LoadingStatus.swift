//
//  LoadingStatus.swift
//  Utilities
//
//  Created by Qiang Huang on 11/20/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

@objc public protocol LoadingStatusProtocol: NSObjectProtocol {
    @objc var running: Bool { get set }
}

public final class LoadingStatus: NSObject, SingletonProtocol, LoadingStatusProtocol {
    public static var shared: LoadingStatus = {
        LoadingStatus()
    }()

    @objc public dynamic var running: Bool = false
    private var runningCount: Int = 0 {
        didSet {
            if runningCount != oldValue {
                running = runningCount > 0
            }
        }
    }

    public func plus() {
        runningCount += 1
    }

    public func minus() {
        runningCount -= 1
    }
}
