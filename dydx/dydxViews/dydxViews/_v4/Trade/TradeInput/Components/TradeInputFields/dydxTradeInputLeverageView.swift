//
//  dydxTradeInputLeverageView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities
import dydxFormatter
import UIToolkits

public class dydxTradeInputLeverageViewModel: PlatformTextInputViewModel {
    private lazy var leverageSlider: GradientSlider = {
        let leverageSlider = GradientSlider()
        leverageSlider.setThumbImage(ImageFactory.shared.sliderThumb, for: .normal)
        leverageSlider.gradientImage = ImageFactory.shared.sliderLine
        leverageSlider.minimumValue = 0.0
        leverageSlider.maximumValue = 1.0
        leverageSlider.isContinuous = true
        leverageSlider.addTarget(self, action: #selector(leverageSlide(slider:event:)), for: .valueChanged)
        return leverageSlider
    }()

    @Published public var leverage: Double = 0 {
        didSet {
            if leverage != oldValue {
                value = dydxFormatter.shared.raw(number: abs(leverage) as NSNumber, digits: 2)

                if leverage < 0 {
                    side = SideTextViewModel(side: .short, coloringOption: .colored)
                } else if leverage > 0 {
                    side = SideTextViewModel(side: .long, coloringOption: .colored)
                } else {
                    side = SideTextViewModel(side: .custom(DataLocalizer.localize(path: "APP.GENERAL.NONE")), coloringOption: .colored)
                }
            }
        }
    }

    @Published private var side: SideTextViewModel?

    @Published public var positionLeverage: Double?
    @Published public var maxLeverage: Double?
    @Published public var tradeSide: AppOrderSide?

    public static var previewValue: dydxTradeInputLeverageViewModel = {
        let vm = dydxTradeInputLeverageViewModel(label: "Leverage", value: "1.0")
        return vm
    }()

    public init(label: String? = nil, value: String? = nil, placeHolder: String? = nil, contentType: UITextContentType? = nil, onEdited: ((String?) -> Void)? = nil) {
        super.init(label: label, value: value, placeHolder: placeHolder, inputType: .decimalDigits, contentType: contentType, onEdited: onEdited)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView { [weak self] style in
            AnyView(
                VStack {
                    self?.createInput(parentStyle: style, inputView: view)
                    self?.createSlider(parentStyle: style)
                }
            )
        }
    }

    public override func valueChanged(value: String?) {
        // Override the parent's valueChange() since the text input does not
        // contain signed value.  We will call sendChange() to send update
        guard let value = value?.unlocalizedNumericValue else {
            return
        }
        let inputValue: Double
        switch side?.side {
        case .long:
            inputValue = Double(value) ?? 0
        case .short:
            inputValue = (Double(value) ?? 0) * -1
        default:
            inputValue = Double(value) ?? 0
        }
        let signedleverage = dydxFormatter.shared.raw(number: leverage as NSNumber, digits: 2)
        let signedValue = dydxFormatter.shared.raw(number: inputValue as NSNumber, digits: 2)
        if signedleverage != signedValue {
            leverage = inputValue
            sendChange()
        }
    }

    private func createInput(parentStyle: ThemeStyle, inputView: PlatformView) -> some View {
        HStack {
            inputView
                .frame(maxWidth: .infinity)
            side?.createView(parentStyle: parentStyle.themeFont(fontSize: .smaller))
                .padding(12)
                .onTapGesture { [weak self] in
                    guard let leverage = self?.leverage, leverage != 0 else {
                        return
                    }
                    self?.leverage = leverage * -1
                    self?.sendChange()
                }
        }
        .makeInput()
    }

    private func createSlider(parentStyle: ThemeStyle) -> some View {
        adjustSlider()

        return VStack {
            leverageSlider.swiftUIView

            HStack {
                if let leverageLeft = leverageLeft {
                    Text((dydxFormatter.shared.raw(number: NSNumber(value: abs(leverageLeft)), digits: 2) ?? "") + "x")
                }
                Spacer()
                if let leverageRight = leverageRight {
                    Text((dydxFormatter.shared.raw(number: NSNumber(value: abs(leverageRight)), digits: 2) ?? "") + "x")
                }
            }
            .themeColor(foreground: .textTertiary)
            .themeFont(fontSize: .smaller)
        }
    }

    private let leverageDebouncer = Debouncer()
    private var slidingLeverage = false

    private func sendChange() {
        let signedValue = dydxFormatter.shared.raw(number: leverage as NSNumber, digits: 2)
        onEdited?(signedValue)
    }

    @objc private func leverageSlide(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            let sliderValue = leverageSlider.value
            let throttled: Bool
            switch touchEvent.phase {
            case .began:
                throttled = false
                PlatformView.hideKeyboard()
                slidingLeverage = true

            case .ended, .cancelled:
                throttled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.slidingLeverage = false
                }

            default:
                throttled = true
            }

            updateLeverage(sliderValue: Double(sliderValue), throttled: throttled)
        }
    }

    private func updateLeverage(sliderValue: Double, throttled: Bool) {
        if let left = leverageLeft, let right = leverageRight {
            var leverage = sliderValue * (right - left) + left
            // round to 0.x
            if leverage > Double.zero {
                leverage = Double(Int(leverage * 10 + 0.5)) / 10.0
            } else {
                leverage = Double(Int(leverage * 10 - 0.5)) / 10.0
            }
            let newValue: Double
            if leverage >= left && leverage <= right && leverage != .zero {
                newValue = leverage
            } else {
                newValue = 0
            }
            self.leverage = newValue
            self.sendChange()

//            if right - left != 0 {
//                let shouldUpdate = throttled == false || abs(self.leverage - newValue) / abs(right - left) > 0.1
//                if shouldUpdate {
//                    self.leverage = newValue
//                    self.sendChange()
//                }
//            } else {
//                self.leverage = newValue
//                self.sendChange()
//            }
        }
    }

    private func adjustSlider() {
        if slidingLeverage == false, let left = leverageLeft, let right = leverageRight, let maxLeverage = maxLeverage {
            if right != left {
                leverageSlider.leftPercentage = (left + maxLeverage) / (right - left)
                leverageSlider.rightPercentage = (maxLeverage - right) / (right - left)
            } else {
                if left > 0.0 {
                    leverageSlider.leftPercentage = 100.0
                    leverageSlider.rightPercentage = 0.0
                } else {
                    leverageSlider.leftPercentage = 0.0
                    leverageSlider.rightPercentage = 100.0
                }
            }

            if right > left {
                var sliderValue = (leverage - left) / (right - left)
                sliderValue = max(0.0, sliderValue)
                sliderValue = min(1.0, sliderValue)

                leverageSlider.value = Float(sliderValue)
            }
        }
    }

    private var leverageLeft: Double? {
        switch tradeSide {
        case .BUY:
            return positionLeverage

        case .SELL:
            return (maxLeverage ?? 0) * -1

        default:
            return nil
        }
    }

    private var leverageRight: Double? {
        switch tradeSide {
        case .BUY:
            return maxLeverage

        case .SELL:
            return positionLeverage

        default:
            return nil
        }
    }
}

#if DEBUG
struct dydxTradeInputLeverageView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputLeverageViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct ddydxTradeInputLeverageView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputLeverageViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
