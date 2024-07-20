//
//  dydxSliderView.swift
//  dydxViews
//
//  Created by Michael Maguire on 7/19/24.
//

import SwiftUI
import PlatformUI

struct dydxSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    @Binding var value: Double

    private let thumbRadius: CGFloat = 11

    var body: some View {

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                track(width: geometry.size.width)
                cursor(geometry: geometry)
            }
        }
        .frame(height: thumbRadius * 2)
    }

    private func cursor(geometry: GeometryProxy) -> some View {
        let draggableLength = (geometry.size.width - thumbRadius * 2)
        let dragPortion = (value - minValue)/(maxValue - minValue) * draggableLength
        let xOffset = min(max(0, dragPortion), draggableLength)
        return Rectangle()
            .fill(ThemeColor.SemanticColor.layer7.color)
            .frame(width: thumbRadius * 2, height: thumbRadius * 2)
            .borderAndClip(style: .circle, borderColor: .textTertiary)
            .offset(x: xOffset)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ gesture in
                        updateValue(with: gesture, geometry: geometry)
                    })
            )
    }

    private func track(width: Double) -> some View {
        let tickWidth = 1.5
        let tickSpacing = 5.0
        let spacerIndent = thumbRadius - tickWidth/2
        let tickAreaWidth = (width - spacerIndent * 2)
        // there is one more tick than there is a space, so subtract an extra tick width from the total available width
        // then round up and adjust tick spacing down if necessary
        let numTicks = ((tickAreaWidth - tickWidth) / (tickWidth + tickSpacing) + 1).rounded(.up)
        let numSpacers = numTicks - 1
        let tickSpacingAdjusted = (tickAreaWidth - (numTicks * tickWidth))/numSpacers

        let trackIndentSpacer = Spacer()
            .frame(width: spacerIndent)
        return HStack(spacing: 0) {
            trackIndentSpacer
            HStack(spacing: tickSpacingAdjusted) {
                ForEach(0..<Int(max(0, numTicks)), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: tickWidth/2)
                        .frame(width: tickWidth, height: 8)
                }
            }
            trackIndentSpacer
        }
        .frame(height: 8)
    }

    private func updateValue(with gesture: DragGesture.Value, geometry: GeometryProxy) {
        // makes a subtle difference to move the slider constant with user gesture rather than with a multiplier speed
        // otherwise slider jumps on initial tap as well
        let dragTouchLocationCentered = gesture.location.x - thumbRadius
        if dragTouchLocationCentered < 0 {
            value = minValue
        } else if dragTouchLocationCentered > geometry.size.width - thumbRadius * 2 {
            value = maxValue
        } else {
            let dragPortion = dragTouchLocationCentered / (geometry.size.width - thumbRadius * 2)
            let newValue = (maxValue - minValue) * dragPortion + minValue
            value = min(max(newValue, minValue), maxValue)
        }
    }
}
