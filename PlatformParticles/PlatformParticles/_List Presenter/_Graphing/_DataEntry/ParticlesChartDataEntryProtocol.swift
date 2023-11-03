//
//  ParticlesChartDataEntryProtocol.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/29/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Charts
import ObjectiveC
import ParticlesKit
import UIKit
import Utilities

extension ChartDataEntry {
    private var weakModel: Weak<ModelObjectProtocol>? {
        get {
            return data as? Weak<ModelObjectProtocol>
        }
        set {
            data = newValue
        }
    }

    @objc public var model: ModelObjectProtocol? {
        get {
            return weakModel?.object
        }
        set {
            if model !== newValue {
                let oldValue = model
                if let newValue = newValue {
                    weakModel = Weak<ModelObjectProtocol>(newValue)
                } else {
                    weakModel = nil
                }
                didSetModel(oldValue: oldValue)
            }
        }
    }

    @objc open func didSetModel(oldValue: ModelObjectProtocol?) {
        sync()
    }
    
    @objc open func sync() {
    }
}

public protocol ParticlesChartDataEntryProtocol: ChartDataEntry {
    var dataSet: Weak<ChartDataSet> { get set }
    var notifierDebouncer: Debouncer { get }
}

public extension ParticlesChartDataEntryProtocol {
    var color: UIColor? {
        return nil
    }
    
    func notify() {
        if let particlesDataSet = dataSet.object as? ParticlesChartDataSetProtocol {
//            particlesDataSet.notify()
        } else {
//            dataSet.object?.notifyDataSetChanged()
        }
    }
}
