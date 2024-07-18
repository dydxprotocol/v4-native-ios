//
//  dydxSliderTextInput.swift
//  dydxViews
//
//  Created by Michael Maguire on 7/18/24.
//

import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities

public class dydxSliderTextInputViewModel: PlatformViewModel {
    fileprivate lazy var placeholder: String = dydxFormatter.shared.raw(number: .zero, size: stepSize) ?? ""
    @Published public var stepSize: String? {
        didSet {
            guard let stepSize else { return }
            placeholder = dydxFormatter.shared.raw(number: .zero, size: stepSize) ?? ""
        }
    }
    @Published public var minimumValue: Double = 0
    @Published public var maximumValue: Double = 0
    @Published public var value: Double = 0
    public var valueAsString: String {
        get {
            dydxFormatter.shared.raw(number: value, size: stepSize) ?? ""
        }
        set {
            self.value = Double(value)
        }
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self, minimumValue != maximumValue else { return PlatformView.emptyView.wrappedInAnyView() }
            return dydxSliderTextInput(sliderViewModel: self).wrappedInAnyView()
        }
    }
}

private struct dydxSlider: View {
    @Binding var value: Double

    let minValue: Double
    let maxValue: Double
    private let thumbRadius: CGFloat = 11

    var body: some View {

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                track(width: geometry.size.width)

                Rectangle()
                    .fill(ThemeColor.SemanticColor.layer7.color)
                    .frame(width: thumbRadius * 2, height: thumbRadius * 2)
                    .borderAndClip(style: .circle, borderColor: .textTertiary)
                    .offset(x: CGFloat(value/(maxValue - minValue)) * (geometry.size.width - thumbRadius * 2))

                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ gesture in
                                updateValue(with: gesture, in: geometry)
                            })
                    )

            }
        }
        .frame(height: thumbRadius * 2)
    }

    private func track(width: Double) -> some View {
        let trackIndentSpacer = Spacer()
            .frame(width: thumbRadius)
        let tickWidth = 1.5
        let tickSpacing = 5.0
        // there is one more tick than there is a space, so subtract an extra tick width from the total available width
        let numTicks = (width - thumbRadius * 2 - tickWidth) / (tickWidth + tickSpacing)
        return HStack(spacing: 0) {
            trackIndentSpacer
            HStack(spacing: tickSpacing) {
                ForEach(0..<Int(numTicks), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: tickWidth/2)
                        .themeColor(background: .textTertiary)
                        .frame(width: tickWidth, height: 8)
                }
            }
            trackIndentSpacer
        }
        .frame(height: 8)
    }

    private func updateValue(with gesture: DragGesture.Value, in geometry: GeometryProxy) {
        // makes a subtle difference to move the slider constant with user gesture rather than with a multiplier speed
        // otherwise slider jumps on initial tap as well
        let tapLocationCentered = gesture.location.x - thumbRadius
        if tapLocationCentered < 0 {
            value = minValue
        } else if tapLocationCentered > geometry.size.width - thumbRadius * 2 {
            value = maxValue
        } else {
            let dragPortion = tapLocationCentered / (geometry.size.width - thumbRadius * 2)
            let newValue = (maxValue - minValue) * dragPortion
            value = min(max(newValue, minValue), maxValue)
        }
    }
}

private struct dydxSliderTextInput: View {
    @StateObject var sliderViewModel: dydxSliderTextInputViewModel

    var slider: some View {
        dydxSlider(value: $sliderViewModel.value, minValue: sliderViewModel.minimumValue, maxValue: sliderViewModel.maximumValue)
    }

    var textInput: some View {
        PlatformInputView(model: .init(
            label: "Test",
            labelAccessory: nil,
            value: $sliderViewModel.valueAsString,
            valueAccessory: nil,
            currentValue: sliderViewModel.valueAsString,
            placeHolder: sliderViewModel.placeholder,
            keyboardType: .decimalPad,
            onEditingChanged: nil,
            truncateMode: .middle,
            focusedOnAppear: false)
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            slider
            textInput
                .makeInput()
                .frame(width: 114)
        }
    }
}
