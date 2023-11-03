//
//  BackgroundTasksPoolInteractor.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/5/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit

internal class BackgroundTask: NSObject, ModelObjectProtocol {
    var identifier: String
    var progress: NSNumber?

    public init(identifier idText: String) {
        identifier = idText
        super.init()
    }
}

internal class BackgroundTasksPoolInteractor: DataPoolInteractor {
    public var tasks: [String: BackgroundTask]? {
        return data as? [String: BackgroundTask]
    }

    public func add(task: BackgroundTask) {
        willChangeValue(forKey: "data")
        if data == nil {
            data = [:]
        }
        data?[task.identifier] = task
        didChangeValue(forKey: "data")
    }

    public func remove(identifier: String) {
        willChangeValue(forKey: "data")
        data?[identifier] = nil
        didChangeValue(forKey: "data")
    }
}
