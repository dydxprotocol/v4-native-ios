//
//  AppState.swift
//  Utilities
//
//  Created by Qiang Huang on 4/26/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Foundation

public typealias ForegroundTask = ()->Void

public final class AppState: NSObject, SingletonProtocol {
    public static var shared: AppState = AppState()
    
    @objc public private(set) dynamic var background: Bool = false {
        didSet {
            didSetBackground(oldValue: oldValue)
        }
    }

    private var foregroundToken: NotificationToken?
    private var backgroundToken: NotificationToken?
    
    private var foregroundTasks: [ForegroundTask] = []

    override public init() {
        super.init()
        backgroundToken = NotificationCenter.default.observe(notification: UIApplication.didEnterBackgroundNotification, do: { [weak self] _ in
            self?.background = true
        })
        foregroundToken = NotificationCenter.default.observe(notification: UIApplication.willEnterForegroundNotification, do: { [weak self] _ in
            self?.background = false
        })
    }
    
    public func runForegrounding(task: @escaping ForegroundTask) {
        if background {
            foregroundTasks.append(task)
        } else {
            task()
        }
    }
    
    private func didSetBackground(oldValue: Bool) {
        if background != oldValue {
            if !background {
                for task in foregroundTasks {
                    task()
                }
                foregroundTasks = []
            }
        }
    }
}
