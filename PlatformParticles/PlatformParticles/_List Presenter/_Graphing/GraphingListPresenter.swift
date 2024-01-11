//
//  GraphingListPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 3/6/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Charts
import Differ
import ParticlesKit
import UIKit
import UIToolkits
import Utilities

open class GraphingListPresenter: NativeListPresenter {
    @IBInspectable public dynamic var limit: Int = 0
    @IBInspectable public dynamic var label: String?
    @IBInspectable public dynamic var color: UIColor? {
        didSet {
            didSetColor(oldValue: oldValue)
        }
    }

    public var allowColorOverride = true

    @IBInspectable public dynamic var showLabel: Bool = false
    @IBInspectable public dynamic var highlightEnabled: Bool = false
    @IBInspectable public dynamic var highlightLineWidth: CGFloat = 0.5
    @IBInspectable public dynamic var highlightColor: UIColor?
    @IBInspectable public dynamic var highlightPhase: CGFloat = 0.0
    @IBInspectable public dynamic var highlightDash: CGFloat = 0.0

    private var pendingGraphingSet: ParticlesChartDataSetProtocol? {
        didSet {
            didSetPendingGraphingSet(oldValue: oldValue)
        }
    }

    @objc public dynamic var graphingSet: ChartDataSet?

    @objc public dynamic var colors: [UIColor]?

    @objc public dynamic var graphingLimitsProvider: GraphingLimitsProviderProtocol?

    private func didSetPendingGraphingSet(oldValue: ParticlesChartDataSetProtocol?) {
        changeObservation(from: oldValue, to: pendingGraphingSet, keyPath: "syncing") { [weak self] _, _, _, animated in
            if animated {
                if let dataSet = (self?.pendingGraphingSet as? ParticlesChartDataSetProtocol), dataSet.syncing == false {
                    self?.graphingSet = self?.pendingGraphingSet
                    if let color = self?.color, self?.allowColorOverride ?? false {
                        self?.graphingSet?.colors = [color]
                    }
                }
            } else {
                self?.graphingSet = nil
            }
        }
    }

    override open func update() {
        current = pending
        if let current = current, current.count > 0 {
            if let interactor = interactor, pendingGraphingSet === nil {
                let dataSet = graphingDataSet()
                dataSet?.limit = limit
                dataSet?.listInteractor = interactor
                pendingGraphingSet = dataSet
            }
        } else {
            pendingGraphingSet = nil
        }
    }

    override open func filter(items: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        if let linearItmes = items {
            return linearItmes.sorted(by: { (item1, item2) -> Bool in
                item1.order?(ascending: item2) ?? true
            })
        } else {
            return items
        }
    }

    open func graphingDataSet() -> ParticlesChartDataSetProtocol? {
        return nil
    }

    open func didSetColor(oldValue: UIColor?) {
        if let color = color, allowColorOverride {
            graphingSet?.colors = [color]
        }
    }
}

@objc public class LineGraphingListPresenter: GraphingListPresenter {
    @IBInspectable public var autoColor: Bool = false
    @IBInspectable public var increasingColor: UIColor?
    @IBInspectable public var decreasingColor: UIColor?
    @IBInspectable public var drawFilled: Bool = false
    @IBInspectable public var stepped: Bool = false
    @IBInspectable public var smooth: Bool = false
    @IBInspectable public var lineWidth: CGFloat = 2.0
    @IBInspectable public var fillAlpha: CGFloat = 0.3
    @IBInspectable public var circleRadius: CGFloat = 4.0
    @IBInspectable public var circleHoleRadius: CGFloat = 4.0

    override open func graphingDataSet() -> ParticlesChartDataSetProtocol? {
        let dataSet = ParticlesLineChartDataSet()
        dataSet.mode = stepped ? .stepped : (smooth ? .horizontalBezier : .linear)
        dataSet.lineWidth = lineWidth
        dataSet.lineCapType = .round
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.circleRadius = circleRadius
        dataSet.circleHoleRadius = circleHoleRadius
        if let color = self.color ?? UIColor(named: "Light Text") {
            dataSet.setColor(color)
            dataSet.fill = .fillWithCGColor(color.cgColor)
        }

        dataSet.drawFilledEnabled = drawFilled
        dataSet.fillAlpha = fillAlpha
        dataSet.highlightEnabled = highlightEnabled
        dataSet.highlightColor = highlightColor ?? UIColor.label
        dataSet.highlightLineDashPhase = highlightPhase
        dataSet.highlightLineDashLengths = [highlightDash]
        dataSet.highlightLineWidth = highlightLineWidth
        dataSet.label = label
        dataSet.axisDependency = YAxis.AxisDependency.left
        dataSet.drawVerticalHighlightIndicatorEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        return dataSet
    }

    override public func update() {
        if let increasingColor = increasingColor, let decreasingColor = decreasingColor {
            allowColorOverride = true
            if let first = interactor?.list?.first as? LinearGraphingObjectProtocol, let last = interactor?.list?.last as? LinearGraphingObjectProtocol, let firstY = first.lineY?.doubleValue, let lastY = last.lineY?.doubleValue {
                if lastY > firstY {
                    color = increasingColor
                } else if lastY < firstY {
                    color = decreasingColor
                }
            }
            allowColorOverride = false
        }
        super.update()
    }

}

@objc public class BarGraphingListPresenter: GraphingListPresenter {
    @IBInspectable public var increasingColor: UIColor?
    @IBInspectable public var decreasingColor: UIColor?

    override open func graphingDataSet() -> ParticlesChartDataSetProtocol? {
        let dataSet = ParticlesBarChartDataSet()
        dataSet.barBorderWidth = 0.5
        dataSet.drawValuesEnabled = false
        dataSet.axisDependency = YAxis.AxisDependency.right
        dataSet.highlightEnabled = highlightEnabled
        dataSet.highlightColor = highlightColor ?? UIColor.label
        dataSet.highlightLineDashPhase = highlightPhase
        dataSet.highlightLineDashLengths = [highlightDash]
        dataSet.highlightLineWidth = highlightLineWidth
        dataSet.increasingColor = increasingColor
        dataSet.decreasingColor = decreasingColor

        return dataSet
    }
}

@objc public class CandleStickGraphingListPresenter: GraphingListPresenter {
    @IBInspectable var lineWidth: CGFloat = 1.0

    @IBInspectable public var increasingColor: UIColor?
    @IBInspectable public var decreasingColor: UIColor?
    @IBInspectable public var neutralColor: UIColor?

    override open func graphingDataSet() -> ParticlesChartDataSetProtocol? {
        let dataSet = ParticlesCandleChartDataSet()
        dataSet.increasingColor = increasingColor
        dataSet.decreasingColor = decreasingColor
        dataSet.shadowColorSameAsCandle = true
        dataSet.neutralColor = neutralColor
        dataSet.increasingFilled = true
        dataSet.decreasingFilled = true
        dataSet.axisDependency = YAxis.AxisDependency.left
        dataSet.drawValuesEnabled = false
        dataSet.formLineWidth = lineWidth
        dataSet.shadowWidth = 1.0
        dataSet.highlightColor = highlightColor ?? .label
        dataSet.highlightEnabled = highlightEnabled
        dataSet.highlightLineDashPhase = highlightPhase
        dataSet.highlightLineDashLengths = [highlightDash]
        dataSet.highlightLineWidth = highlightLineWidth
        dataSet.drawVerticalHighlightIndicatorEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        return dataSet
    }
}

@objc public class PieGraphingListPresenter: GraphingListPresenter {
    override open func graphingDataSet() -> ParticlesChartDataSetProtocol? {
        let dataSet = ParticlesPieChartDataSet()
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 1
        dataSet.selectionShift = 0
        if let colors = colors {
            dataSet.colors = colors
        }
        return dataSet
    }
}
