//
//  TimeIntervalObjectViewPresenter.swift
//  PlatformParticles
//
//  Created by John Huang on 2/12/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation
import ParticlesKit
import Utilities

@objc open class TimeIntervalObjectViewPresenter: ObjectViewPresenter {
    public var clock: Clock? {
        didSet {
            didSetClock(oldValue: oldValue)
        }
    }
    
    open override func didSetModel(oldValue: ModelObjectProtocol?) {
        super.didSetModel(oldValue: oldValue)
        clock = Clock.shared
    }

    open func didSetClock(oldValue: Clock?) {
        changeObservation(from: oldValue, to: clock, keyPath: #keyPath(Clock.time)) { [weak self] _, _, _, animated in
            self?.displayTime(animated: animated)
        }
    }

    open func displayTime(animated: Bool) {
    }
}

