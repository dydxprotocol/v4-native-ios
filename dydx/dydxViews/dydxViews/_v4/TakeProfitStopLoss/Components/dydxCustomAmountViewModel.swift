//
//  dydxCustomAmountViewModel.swift
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

    @Published private (set) public var isOn: Bool = false
    @Published public var toggleAction: ((Bool) -> Void)?

    @Published public var assetId: String? {
        didSet {
            guard let assetId = assetId else { return }
            labelAccessory = TokenTextViewModel(symbol: assetId)
                .createView(parentStyle: ThemeStyle.defaultStyle.themeFont(fontSize: .smallest))
                .wrappedInAnyView()
        }
    }
    @Published public var stepSize: String? {
        didSet {
            guard let stepSize else { return }
            self.placeHolder = dydxFormatter.shared.raw(number: .zero, size: stepSize)
        }
    }
    @Published public var minimumValue: Float? {
        didSet {
            slider.minimumValue = minimumValue ?? 0
        }
    }
    @Published public var maximumValue: Float? {
        didSet {
            slider.maximumValue = maximumValue ?? 0
        }
    }

    /// Sets value and related UI without triggering action callbacks
    public func programmaticallySet(newValue: String?) {
        isOn = newValue != nil
        setSliderValue(value: newValue)
        value = newValue
    }

    public init() {
        super.init(
            label: DataLocalizer.shared?.localize(path: "APP.GENERAL.AMOUNT", params: nil),
            inputType: .decimalDigits,
            truncateMode: .middle
        )
    }

    private var onOffSwitch: some View {
        PlatformBooleanInputViewModel(label: DataLocalizer.shared?.localize(path: "APP.GENERAL.CUSTOM_AMOUNT", params: nil), labelAccessory: nil, value: isOn.description, valueAccessoryView: nil) { [weak self] value in
            guard let self, let value, let isOn = Bool(value) else { return }
            self.isOn = isOn
            self.toggleAction?(isOn)
        }
        .createView()
        .padding(.trailing, 2) // swiftui bug where toggle view in a scrollview gets clipped without this
    }

    private var input: AnyView? {
        guard isOn else { return nil }
        return super.createView()
            .makeInput()
            .wrappedInAnyView()
    }

    private lazy var slider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.value = 0
        slider.thumbTintColor = ThemeColor.SemanticColor.textSecondary.uiColor
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.addTarget(
            self,
            action: #selector(self.sliderValueChanged),
            for: .valueChanged
        )

        return slider
    }()

    private var sliderBackground: some View {
        GeometryReader { geometry in
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
    }

    private var sliderCompositeView: some View {
        return ZStack(alignment: .center) {
            self.sliderBackground
            self.slider.swiftUIView
        }
    }

    public static var previewValue: dydxCustomAmountViewModel = {
        let vm = dydxCustomAmountViewModel()
        vm.isOn = true
        vm.minimumValue = 0
        vm.maximumValue = 1
        vm.assetId = "ETH"
        vm.stepSize = "0.01"
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            // if min == max, there is no need for a custom amount since there can only be one value
            guard let self = self, minimumValue != maximumValue else { return PlatformView.emptyView.wrappedInAnyView() }
            return VStack(spacing: 15) {
                self.onOffSwitch
                HStack(alignment: .center, spacing: 20) {
                    if self.isOn {
                        self.sliderCompositeView
                        self.input
                    }
                }
            }
            .wrappedInAnyView()
        }
    }

    @objc private func sliderValueChanged(sender: UISlider) {
        guard let stepSize else { return }
        let roundedValue = dydxFormatter.shared.raw(number: NSNumber(value: sender.value), size: stepSize)
        self.value = roundedValue
        slider.value = Parser.standard.asInputDecimal(value)?.floatValue ?? minimumValue ?? 0
        PlatformView.hideKeyboard()
        self.onEdited?(value)
    }

    public override func valueChanged(value: String?) {
        if let stepSize,
           let value = Parser.standard.asInputDecimal(value)?.floatValue {
            let valueWithinRange = min(max(slider.minimumValue, value), slider.maximumValue)
            let roundedValue = dydxFormatter.shared.raw(number: Parser.standard.asInputDecimal(valueWithinRange), size: stepSize)
            super.valueChanged(value: roundedValue)
        } else {
            super.valueChanged(value: "\(minimumValue ?? 0)")
        }
        setSliderValue(value: value)
    }

    private func setSliderValue(value: String?) {
        slider.value = Parser.standard.asDecimal(value)?.floatValue ?? slider.minimumValue
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
