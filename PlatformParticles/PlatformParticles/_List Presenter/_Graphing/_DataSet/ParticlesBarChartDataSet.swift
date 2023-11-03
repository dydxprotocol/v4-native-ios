//
//  ParticlesBarChartDataSet.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 11/4/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Charts
import ParticlesKit
import UIKit
import Utilities

@objc public class ParticlesBarChartDataSet: BarChartDataSet, ParticlesChartDataSetProtocol {
    public var syncDebouncer = Debouncer()

    public var limit: Int = 0
    @objc public dynamic var syncing: Bool = false

    public var increasingColor: UIColor?
    public var decreasingColor: UIColor?

    private lazy var leading: ChartDataEntry = {
        BarChartDataEntry(x: -3, y: 0)
    }()

    private lazy var tailing: ChartDataEntry = {
        BarChartDataEntry(x: 0, y: 0)
    }()

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
        return ParticlesBarChartDataEntry()
    }

    public func replace(entries: [ChartDataEntry]) {
        if entries.count > 0, let first = entries.first as? BarChartDataEntry, let last = entries.last as? BarChartDataEntry {
            leading.x = first.x - 4
            tailing.x = last.x + 4
            var modified = entries
            modified.insert(leading, at: 0)
            modified.append(tailing)
            replaceEntries(modified)
            if let colors = calculateColors(entries: modified) {
                self.colors = colors
            }
        } else {
            replaceEntries(entries)
            if let colors = calculateColors(entries: entries) {
                self.colors = colors
            }
        }
    }

    private func calculateColors(entries: [ChartDataEntry]) -> [UIColor]? {
        if let increasingColor = increasingColor, let decreasingColor = decreasingColor {
            var colors = [UIColor]()
            var previous: ParticlesChartDataEntryProtocol?
            for i in 0 ..< entries.count {
                if let entry = entries[i] as? ParticlesChartDataEntryProtocol {
                    if increasing(entry: entry, previous: previous) {
                        colors.append(increasingColor)
                    } else {
                        colors.append(decreasingColor)
                    }
                    previous = entry
                } else {
                    // first entry is place holder
                    colors.append(UIColor.clear)
                }
            }
            return colors
        } else {
            return nil
        }
    }

    private func increasing(entry: ParticlesChartDataEntryProtocol?, previous: ParticlesChartDataEntryProtocol?) -> Bool {
        if let thisCandle = entry?.model as? CandleGraphingObjectProtocol {
            if let previousCandle = previous?.model as? CandleGraphingObjectProtocol {
                return (thisCandle.candleClose?.doubleValue ?? Double.zero) >= (previousCandle.candleClose?.doubleValue ?? Double.zero)
            } else {
                return (thisCandle.candleClose?.doubleValue ?? Double.zero) >= (thisCandle.candleOpen?.doubleValue ?? Double.zero)
            }
        } else if let thisLinear = entry?.model as? LinearGraphingObjectProtocol {
            if let previousLinear = previous?.model as? LinearGraphingObjectProtocol {
                return (thisLinear.lineY?.doubleValue ?? Double.zero) >= (previousLinear.lineY?.doubleValue ?? Double.zero)
            } else {
                return true
            }
        } else {
            return true
        }
    }
}
