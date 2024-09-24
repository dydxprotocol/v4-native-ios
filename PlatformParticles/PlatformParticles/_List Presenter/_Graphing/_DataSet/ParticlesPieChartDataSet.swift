//
//  ParticlesPieChartDataSet.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 11/4/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import DGCharts
import ParticlesKit
import Utilities

@objc public class ParticlesPieChartDataSet: PieChartDataSet, ParticlesChartDataSetProtocol {
    public var syncDebouncer = Debouncer()
    
    public var limit: Int = 0
    @objc public dynamic var syncing: Bool = false
    
    public var presenter = Weak<GraphingPresenter>()

    public var notifierDebouncer = Debouncer()

    public var listInteractor: ListInteractor? {
        didSet {
            changeObservation(from: oldValue, to: listInteractor, keyPath: #keyPath(ListInteractor.list)) { [weak self] _, _, _, _ in
                self?.sync()
            }
        }
    }

    public func entry() -> ParticlesChartDataEntryProtocol {
        return ParticlesPieChartDataEntry()
    }
}
