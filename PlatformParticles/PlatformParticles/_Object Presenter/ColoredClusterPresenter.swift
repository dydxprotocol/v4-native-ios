//
//  ColoredClusterPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 2/4/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Charts
import ParticlesKit
import UIToolkits

public struct ColorCount {
    var color: UIColor?
    var count: Int = 0
}

open class ColoredClusterPresenter: ObjectPresenter {
    @IBOutlet public var view: UIView?
    @IBOutlet public var pie: PieChartView? {
        didSet {
            if pie !== oldValue {
                pie?.holeRadiusPercent = 0.70
                pie?.legend.enabled = false
                pie?.visible = false
            }
        }
    }

    @IBOutlet var countLabel: UILabel?
    @IBOutlet public var diameterConstraint: NSLayoutConstraint?
    @IBInspectable var autoResizing: Bool = false

    override open var model: ModelObjectProtocol? {
        didSet {
            if model !== oldValue {
                cluster = model as? ClusteredModelObjectProtocol
            }
        }
    }

    open var cluster: ClusteredModelObjectProtocol? {
        didSet {
            if cluster !== oldValue {
                updateCluster()
            }
        }
    }

    open var colors: [String: Int]? {
        return nil
    }

    open var colorCounts: [ColorCount]? {
        if let colors = colors {
            var colorCounts = [ColorCount]()

            for (key, value) in colors {
                if let count = parser.asInt(value) {
                    var colorCount = ColorCount()
                    colorCount.color = ColorPalette.shared.color(text: key)
                    colorCount.count = count
                    colorCounts.append(colorCount)
                }
            }
            return colorCounts.sorted { (colorCount1, colorCount2) -> Bool in
                if let color1 = colorCount1.color, let color2 = colorCount2.color {
                    var gray1: CGFloat = 0
                    var gray2: CGFloat = 0
                    var alpha1: CGFloat = 0
                    var alpha2: CGFloat = 0
                    color1.getWhite(&gray1, alpha: &alpha1)
                    color2.getWhite(&gray2, alpha: &alpha2)
                    if gray1 == gray2 {
                        return alpha1 > alpha2
                    } else {
                        return gray1 < gray2
                    }
                }
                return false
            }
        }
        return nil
    }

    public var count: Int {
        var count: Int = 0
        if let colorCounts = colorCounts {
            for colorCount in colorCounts {
                count += colorCount.count
            }
        }
        return count
    }

    public var chart: PieChartData? {
        didSet {
            if chart !== oldValue {
                if let chart = chart {
                    UIView.animate(pie, type: .fade, direction: .none, duration: UIView.defaultAnimationDuration, animations: {
                        self.pie?.data = chart
                        self.pie?.visible = true
                    }, completion: nil)
                } else {
                    pie?.visible = false
                }
            }
        }
    }

    open func updateCluster() {
        let count = self.count
        if count > 0, let colorCounts = colorCounts {
            countLabel?.text = "\(count)"
            var pieEntries = [PieChartDataEntry]()

            var segments = [UIColor]()
            for colorCount in colorCounts {
                if let color = colorCount.color {
                    pieEntries.append(PieChartDataEntry(value: Double(colorCount.count) / Double(count)))
                    segments.append(color)
                }
            }
            let set = PieChartDataSet(entries: pieEntries, label: nil)
            set.colors = segments
            set.drawIconsEnabled = false
            set.drawValuesEnabled = false
            set.sliceSpace = 1
            set.selectionShift = 0

            chart = PieChartData(dataSet: set)

            if autoResizing {
                let diameter = min(40, log2(CGFloat(count)) * 2 + 32.0)
                diameterConstraint?.constant = diameter
                view?.corner = diameter / 2.0
            }
        } else {
            countLabel?.text = nil
            chart = nil
            if autoResizing {
                diameterConstraint?.constant = 40
                view?.corner = 20
            }
        }
    }
}
