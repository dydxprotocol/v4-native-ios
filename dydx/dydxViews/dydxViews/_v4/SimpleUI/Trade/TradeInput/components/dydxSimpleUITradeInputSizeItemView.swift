//
//  dydxSimpleUITradeInputSizeItemView.swift
//  dydxUI
//
//  Created by Rui Huang on 02/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUITradeInputSizeItemViewModel: PlatformTextInputViewModel {
    public static var previewValue: dydxSimpleUITradeInputSizeItemViewModel = {
        let vm = dydxSimpleUITradeInputSizeItemViewModel(label: nil, value: "1.0")
        vm.tokenSymbol = "ETH"
        vm.size = "111"
        vm.usdcSize = "222"
        vm.placeHolder = "0.000"
        return vm
    }()

    public static let viewHeight = 52.0

    @Published public var tokenSymbol: String? {
        didSet {
            if tokenSymbol != oldValue {
                updateValue()
            }
        }
    }

    @Published public var size: String? {
        didSet {
            if size != oldValue {
                updateValue()
            }
        }
    }

    @Published public var usdcSize: String? {
        didSet {
            if usdcSize != oldValue {
                updateValue()
            }
        }
    }

    @Published public var showingUsdc: Bool = false {
        didSet {
            if showingUsdc != oldValue {
                updateValue()
            }
        }
    }

    private var leftValueAccessoryText: some View {
        let text = showingUsdc ? "$" : ""
        return Text(text)
                .themeFont(fontSize: .large)
                .themeColor(foreground: .textPrimary)
    }

    private var rightValueAccessoryText: some View {
        let text = showingUsdc ? "" : (tokenSymbol ?? "")
        return Text(text)
                .themeFont(fontSize: .large)
                .themeColor(foreground: .textPrimary)
    }

    private func updateValue() {
        if showingUsdc {
            value = usdcSize
        } else {
            value = size
        }
    }

    public init(label: String? = nil, value: String? = nil, placeHolder: String? = nil, contentType: UITextContentType? = nil, onEdited: ((String?) -> Void)? = nil) {
        super.init(label: label, value: value, placeHolder: placeHolder, inputType: .decimalDigits, contentType: contentType, onEdited: onEdited, twoWayBinding: true, textAlignment: .center, dynamicWidth: true)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let inputView = super.createView(parentStyle: parentStyle.themeFont(fontType: .plus, fontSize: .custom(size: 36)), styleKey: styleKey)

        return PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            let view = HStack(alignment: .center, spacing: -8) {
                self?.leftValueAccessoryText
                inputView
                self?.rightValueAccessoryText
            }
                .frame(height: Self.viewHeight)
            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUITradeInputSizeItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputSizeItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUITradeInputSizeItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputSizeItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
