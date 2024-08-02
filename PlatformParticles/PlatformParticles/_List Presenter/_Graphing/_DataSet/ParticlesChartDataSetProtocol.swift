//
//  DataSetNotifierProtocol.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 11/4/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import DGCharts
import CoreVideo
import ObjectiveC
import ParticlesKit
import Utilities

@objc public class GraphingLimit: NSObject {
    var label: String?
    var value: NSNumber?
    var color: String?
}

@objc public protocol GraphingLimitsProviderProtocol: NSObjectProtocol {
    var limits: [GraphingLimit]? { get set }
}

public protocol ParticlesChartDataSetProtocol: ChartDataSet {
    var limit: Int { get set }
    var presenter: Weak<GraphingPresenter> { get set }
    var notifierDebouncer: Debouncer { get }

    var syncing: Bool { get set }
    var syncDebouncer: Debouncer { get set }

    var listInteractor: ListInteractor? { get set }
    func entry() -> ParticlesChartDataEntryProtocol
    func replace(entries: [ChartDataEntry])
    func filter(list: [ModelObjectProtocol]?) -> [ModelObjectProtocol]?
    func sort(list: [ModelObjectProtocol]?) -> [ModelObjectProtocol]?
    func notify()
}

public extension ParticlesChartDataSetProtocol {
    func notify() {
        if !syncing {
            // Console.shared.log("Graphing: Syncing Data")
            presenter.object?.chartView?.notifyDataSetChanged()
            (presenter.object?.chartView as? BarLineChartViewBase)?.autoScaleMinMaxEnabled = true
        }
    }

    func replace(entries: [ChartDataEntry]) {
        replaceEntries(entries)
    }

    func filter(list: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return list
    }

    func sort(list: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        if let list = list {
            if let first = (list.first as? GraphingObjectProtocol)?.graphingX?.doubleValue, let last = (list.last as? GraphingObjectProtocol)?.graphingX?.doubleValue {
                if first < last {
                    return list
                } else {
                    return Array(list.reversed())
                }
            } else {
                return list
            }
        } else {
            return nil
        }
    }

    func sync() {
        let list = listInteractor?.list
        let existing = entries
        var sorted: [ModelObjectProtocol]?
        var entries: [ChartDataEntry]?

        syncing = true
        syncDebouncer.debounce()?.run(backgrounds: [{ [weak self] in
            sorted = self?.sort(list: self?.filter(list: list))
        }, { [weak self] in
            entries = self?.dataEntries(list: sorted, existing: existing)
        }], final: { [weak self] in
            if let entries = entries {
                self?.replace(entries: entries)
            }
            self?.syncing = false
            self?.notify()
        }, delay: nil)
    }

    func dataEntries(list: [ModelObjectProtocol]?, existing: [ChartDataEntry]) -> [ChartDataEntry]? {
        if let list = list {
            var cursor: Int?
            var current: ChartDataEntry?
            if existing.count > 0 {
                cursor = 0
                current = existing[cursor!]
            }
            var entries = [ChartDataEntry]()
//            var limit = limit
//            if limit == 0 || limit > list.count {
//                limit = list.count
//            }
            for i in 0 ..< list.count {
                let model = list[i]
                var found: ChartDataEntry?
                while found === nil, current !== nil {
                    if current?.model === model {
                        found = current
                    }
                    if cursor! < existing.count - 1 {
                        cursor = cursor! + 1
                        current = existing[cursor!]
                    } else {
                        cursor = nil
                        current = nil
                    }
                }
                if let found = found {
                    found.sync()
                    entries.append(found)
                } else {
                    let entry = self.entry()
                    entry.model = model
                    entry.dataSet.object = self
                    entries.append(entry)
                }
            }
            return entries
        } else {
            return nil
        }
    }
}
