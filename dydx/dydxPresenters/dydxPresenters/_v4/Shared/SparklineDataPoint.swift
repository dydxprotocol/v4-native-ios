//
//  SparklineDataPoint.swift
//  dydxPresenters
//
//  Created by Rui Huang on 5/1/23.
//

import Foundation
import PlatformParticles
import ParticlesKit
import Abacus
import Utilities
import dydxChart

final class SparklineDataPoint: DictionaryEntity, LinearGraphingObjectProtocol {
    // MARK: LinearGraphingObjectProtocol

    private(set) var lineY: NSNumber?

    private(set) var graphingX: NSNumber?

    private(set) var lineValue: Double?
    private(set) var index: Int?

    init(lineValue: Double, index: Int) {
        self.lineValue = lineValue
        self.index = index
        super.init()

        lineY = NSNumber(value: lineValue)
        graphingX = NSNumber(value: index)
    }

    required init() {}
}
