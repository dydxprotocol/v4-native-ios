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

    private var valueAccessoryTextAnyView: AnyView {
        let text = showingUsdc ? "USD" : tokenSymbol ?? ""
        return AnyView(
            TokenTextViewModel(symbol: text)
                .createView(parentStyle: .defaultStyle.themeFont(fontSize: .small))
        )
    }

    private func updateValue() {
        if showingUsdc {
            value = usdcSize
        } else {
            value = size
        }
        valueAccessoryView = valueAccessoryTextAnyView
    }

    public init(label: String? = nil, value: String? = nil, placeHolder: String? = nil, contentType: UITextContentType? = nil, onEdited: ((String?) -> Void)? = nil) {
        super.init(label: label, value: value, placeHolder: placeHolder, inputType: .decimalDigits, contentType: contentType, onEdited: onEdited, twoWayBinding: true, textAlignment: .center)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle.themeFont(fontType: .plus, fontSize: .custom(size: 36)), styleKey: styleKey)
        return PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { _ in
            AnyView(view.frame(height: Self.viewHeight))
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
