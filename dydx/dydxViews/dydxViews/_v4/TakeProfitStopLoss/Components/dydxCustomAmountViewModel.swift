//
//  dydxTriggerPriceInputViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/2/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities

public class dydxCustomAmountViewModel: PlatformTextInputViewModel {
    @Published public var assetId: String? {
        didSet {
            guard let assetId = assetId else { return }
            labelAccessory = TokenTextViewModel(symbol: assetId)
                .createView(parentStyle: ThemeStyle.defaultStyle.themeFont(fontSize: .smallest))
                .wrappedInAnyView()
        }
    }
    @Published public var stepSizeDecimals: Int? {
        didSet {
            guard let stepSizeDecimals else { return }
            self.placeHolder = dydxFormatter.shared.raw(number: .zero, digits: stepSizeDecimals)
        }
    }
    @Published public var minAmount: Double?
    @Published public var maxAmount: Double?
    @Published private var isOn: Bool = false

    public init() {
        super.init(
            label: DataLocalizer.shared?.localize(path: "APP.GENERAL.AMOUNT", params: nil),
            inputType: .decimalDigits,
            truncateMode: .middle
        )
    }

    private var onOffSwitch: PlatformView {
        PlatformBooleanInputViewModel(label: DataLocalizer.shared?.localize(path: "APP.GENERAL.CUSTOM_AMOUNT", params: nil), labelAccessory: nil, value: isOn.description, valueAccessoryView: nil) { [weak self] value in
            guard let self, let value, let isOn = Bool(value) else { return }
            self.isOn = isOn
            self.onEdited?(isOn ? value : nil)
        }
        .createView()
    }

    private var input: AnyView? {
        guard isOn else { return nil }
        return super.createView()
            .makeInput()
            .wrappedInAnyView()
    }

    private var slider: UISliderView? {
        UISliderView(value: inputBindingIgnoringFocus,
                     minValue: minAmount,
                     maxValue: maxAmount,
                     stepSizeDecimals: stepSizeDecimals,
                     thumbColor: ThemeColor.SemanticColor.textSecondary.uiColor,
                     minTrackColor: .clear,
                     maxTrackColor: .clear)
    }

    private var sliderBackground: AnyView? {
        GeometryReader {[weak self] geometry in
            guard let self = self else { return EmptyView().wrappedInAnyView() }
            let tickWidth = 1.5
            let tickSpacing = 5.0
            let numTicks = (geometry.size.width - tickSpacing * 2) / (tickWidth + tickSpacing)
            return HStack(spacing: tickSpacing) {
                Spacer()
                HStack(spacing: tickSpacing) {
                    ForEach(0..<Int(numTicks), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: tickWidth/2)
                            .themeColor(background: .textTertiary)
                            .frame(width: tickWidth, height: 8)
                    }
                }
                Spacer()
            }
            .wrappedInAnyView()
        }
        .frame(height: 8)
        .wrappedInAnyView()
    }

    private var sliderCompositeView: AnyView? {
        guard isOn else { return nil }
        return ZStack(alignment: .center) {
            self.sliderBackground
            self.slider
        }
        .wrappedInAnyView()
    }

    public static var previewValue: dydxTriggerPriceInputViewModel = {
        let vm = dydxTriggerPriceInputViewModel(triggerType: .takeProfit)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            // if min == max, there is no need for a custom amount since there can only be one value
            guard let self = self, minAmount != maxAmount else { return PlatformView.emptyView.wrappedInAnyView() }
            return VStack(spacing: 15) {
                self.onOffSwitch
                HStack(alignment: .center, spacing: 20) {
                    self.sliderCompositeView
                    self.input
                }
            }
            .wrappedInAnyView()
        }
    }

    public override func valueChanged(value: String?) {
        guard let stepSizeDecimals else {
            preconditionFailure("need to set step size first")
        }
        let roundedValue = dydxFormatter.shared.raw(number: Parser.standard.asInputDecimal(value), digits: stepSizeDecimals)
        super.valueChanged(value: roundedValue)
    }
}

public struct UISliderView: UIViewRepresentable {
    @Binding var value: String

    private var tickRoundedValue: Float {
        if let value = dydxFormatter.shared.raw(number: Parser.standard.asInputDecimal(value), digits: self.stepSizeDecimals),
            let valueAsFloat = Float(value) {
            return valueAsFloat
        }
        return minValue
    }

    public init?(value: Binding<String>?, minValue: Double?, maxValue: Double?, stepSizeDecimals: Int?, thumbColor: UIColor, minTrackColor: UIColor, maxTrackColor: UIColor) {
        guard let value = value,
              let minValue = minValue,
              let maxValue = maxValue,
              let stepSizeDecimals = stepSizeDecimals else { return nil }
        self._value = value
        self.minValue = Float(minValue)
        self.maxValue = Float(maxValue)
        self.stepSizeDecimals = stepSizeDecimals
        self.thumbColor = thumbColor
        self.minTrackColor = minTrackColor
        self.maxTrackColor = maxTrackColor
    }

    var minValue: Float
    var maxValue: Float
    var stepSizeDecimals: Int
    var thumbColor: UIColor
    var minTrackColor: UIColor
    var maxTrackColor: UIColor

    public class Coordinator: NSObject {
        var value: Binding<String>
        var stepSizeDecimals: Int

        init(stepSizeDecimals: Int, value: Binding<String>) {
            self.stepSizeDecimals = stepSizeDecimals
            self.value = value
        }

        @objc func valueChanged(_ sender: UISlider) {
            guard let rounded = dydxFormatter.shared.raw(number: Double(sender.value), digits: self.stepSizeDecimals) else { return }
            self.value.wrappedValue = rounded
        }
    }

    public func makeCoordinator() -> UISliderView.Coordinator {
        Coordinator(stepSizeDecimals: stepSizeDecimals, value: $value)
    }

    public func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.thumbTintColor = thumbColor
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = tickRoundedValue
        slider.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )

        return slider
    }

    public func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = tickRoundedValue
    }
}

#if DEBUG
struct dydxCustomAmountViewModel_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxCustomAmountViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
