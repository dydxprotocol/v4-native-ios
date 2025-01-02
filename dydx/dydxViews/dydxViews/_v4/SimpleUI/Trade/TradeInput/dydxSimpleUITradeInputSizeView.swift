//
//  dydxSimpleUITradeInputSizeView.swift
//  dydxUI
//
//  Created by Rui Huang on 02/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUITradeInputSizeViewModel: PlatformTextInputViewModel {
    public static var previewValue: dydxSimpleUITradeInputSizeViewModel = {
        let vm = dydxSimpleUITradeInputSizeViewModel(label: "Amount", value: "1.0")
        vm.tokenSymbol = "ETH"
        vm.size = "111"
        vm.usdcSize = "222"
        return vm
    }()

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
            Text(text)
                .themeFont(fontSize: .smaller)
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
        super.init(label: label, value: value, placeHolder: placeHolder, inputType: .decimalDigits, contentType: contentType, onEdited: onEdited)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle.themeFont(fontSize: .custom(size: 32)), styleKey: styleKey)
        return PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            AnyView(
                VStack {
                    view
                    Spacer()
                }
                .frame(height: 108)
            )
        }
    }
}

#if DEBUG
struct dydxSimpleUITradeInputSizeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputSizeViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUITradeInputSizeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputSizeViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
