//
//  TransferAmountBox.swift
//  dydxUI
//
//  Created by Rui Huang on 4/7/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class TransferAmountBoxModel: PlatformTextInputViewModel {
    @Published public var maxAction: (() -> Void)?
    @Published public var maxAmount: Double?
    @Published public var stepSize: Double?
    @Published public var tokenText: TokenTextViewModel?

    private var transferAmount: Double? {
        Parser.standard.asNumber(value)?.doubleValue
    }

    public static var previewValue: TransferAmountBoxModel = {
        let vm = TransferAmountBoxModel(label: "Limit Price", value: "100.0", placeHolder: "0.000")
        vm.maxAmount = 1000
        vm.stepSize = 0.001
        vm.tokenText = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView { style in
            AnyView(
                ZStack(alignment: .bottom) {
                    HStack {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.AVAILABLE"))
                            .themeFont(fontSize: .medium)
                            .themeColor(foreground: .textTertiary)

                        self.tokenText?.createView(parentStyle: style.themeFont(fontSize: .smaller))

                        Spacer()

                        self.amountChange?.createView(parentStyle: style)
                    }
                    .padding()
                    .padding(.top, 6)
                    .themeColor(background: .layer0)
                    .cornerRadius(12, corners: [.bottomLeft, .bottomRight])

                    VStack {
                        HStack {
                            view

                            let buttonContent = Text(DataLocalizer.localize(path: "APP.GENERAL.MAX"))
                                .themeFont(fontSize: .medium)
                                .wrappedViewModel

                            PlatformButtonViewModel(content: buttonContent, type: .pill, state: .secondary, action: { [weak self] in

                                PlatformView.hideKeyboard()

                                let amount = self?.maxAmount ?? 0
                                if amount > 0 {
                                    self?.value = "\(amount)"
                                    self?.valueChanged(value: self?.value)
                                    self?.maxAction?()
                                }
                            })
                                .createView(parentStyle: style)
                                .padding(.trailing, 8)
                        }
                        .makeInput()
                        .frame(height: 74)

                        Spacer(minLength: 48)
                    }
                }
                .frame(height: 120)
            )
        }
    }

    public override var header: PlatformViewModel {
        Text(DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"))
            .themeFont(fontSize: .smaller)
            .wrappedViewModel
    }

    private var amountChange: PlatformViewModel? {
        guard let maxAmount = maxAmount else {
            return Text("-").themeFont(fontSize: .small).wrappedViewModel
        }

        let maxAmountText = dydxFormatter.shared.raw(number: NSNumber(value: maxAmount), size: self.stepSize?.shortString ?? "0.001")

        if maxAmount == 0 {
            return Text("0").themeFont(fontSize: .small).wrappedViewModel
        } else if transferAmount ?? 0 == 0 {
             return Text(maxAmountText ?? "0").themeFont(fontSize: .small).wrappedViewModel
        } else {
            let stepSize = Parser.standard.asString(self.stepSize)
            let before = SizeTextModel(amount: NSNumber(value: maxAmount), stepSize: stepSize)
            let remaining = maxAmount - (transferAmount ?? 0)
            let after = SizeTextModel(amount: NSNumber(value: max(0, remaining)), stepSize: stepSize)
            return SizeChangeModel(before: before, after: after)
        }
    }
}

#if DEBUG
struct TransferAmountBox_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return TransferAmountBoxModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct TransferAmountBox_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return TransferAmountBoxModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
