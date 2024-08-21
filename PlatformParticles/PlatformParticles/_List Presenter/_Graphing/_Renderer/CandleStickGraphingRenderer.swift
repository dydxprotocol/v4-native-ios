//
//  CandleStickGraphingRenderer.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/29/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Charts
import Foundation

class CandleStickGraphingRenderer: CandleStickChartRenderer {
    private var _xBounds = XBounds() // Reusable XBounds object

    private var minValue: Double
    private var maxValue: Double

    // New constructor
    init(view: CandleStickChartView, minValue: Double, maxValue: Double) {
        self.minValue = minValue
        self.maxValue = maxValue

        super.init(dataProvider: view, animator: view.chartAnimator, viewPortHandler: view.viewPortHandler)
    }

    // Override draw function
    override func drawValues(context: CGContext) {
        guard
            let dataProvider = dataProvider,
            let candleData = dataProvider.candleData
        else { return }

        guard isDrawingValuesAllowed(dataProvider: dataProvider) else { return }

        let dataSets = candleData.dataSets

        let phaseY = animator.phaseY

        var pt = CGPoint()

        for i in 0 ..< dataSets.count {
            guard let dataSet = dataSets[i] as? IBarLineScatterCandleBubbleChartDataSet
            else { continue }

            let valueFont = dataSet.valueFont
            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix

            _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)

            let lineHeight = valueFont.lineHeight
            let yOffset: CGFloat = lineHeight + 5.0

            for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1) {
                guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { break }

                guard e.high == maxValue || e.low == minValue else { continue }

                pt.x = CGFloat(e.x)
                if e.high == maxValue {
                    pt.y = CGFloat(e.high * phaseY)
                } else if e.low == minValue {
                    pt.y = CGFloat(e.low * phaseY)
                }
                pt = pt.applying(valueToPixelMatrix)

                if !viewPortHandler.isInBoundsRight(pt.x) {
                    break
                }

                if !viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y) {
                    continue
                }

                if dataSet.isDrawValuesEnabled {
                    // In this part we draw min and max values
                    var textValue: String?
                    var align: NSTextAlignment = .center
                    if e.high == maxValue {
                        pt.y -= yOffset
                        textValue = "←  " + String(maxValue)
                        align = .left
                    } else if e.low == minValue {
                        pt.y += yOffset / 5
                        textValue = String(minValue) + "  →"
                        align = .right
                    }

                    if let textValue = textValue {
                        ChartUtils.drawText(
                            context: context,
                            text: textValue,
                            point: CGPoint(
                                x: pt.x,
                                y: pt.y),
                            align: align,
                            attributes: [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: dataSet.valueTextColorAt(j)])
                    }
                }
            }
        }
    }
}
