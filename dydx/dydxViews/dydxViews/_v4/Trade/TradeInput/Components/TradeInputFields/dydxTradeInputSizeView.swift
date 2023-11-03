//
//  dydxTradeInputSizeView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputSizeViewModel: PlatformTextInputViewModel {
    public static var previewValue: dydxTradeInputSizeViewModel = {
        let vm = dydxTradeInputSizeViewModel(label: "Amount", value: "1.0")
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
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            AnyView(
                ZStack {
                    VStack {
                        Spacer()
                        self?.createBottomView(parentStyle: style)
                    }

                    VStack {
                        self?.createTopView(inputView: view, parentStyle: style)
                        Spacer()
                    }
                }
                .frame(height: 108)
            )
        }
    }

    private func createTopView(inputView: PlatformView, parentStyle: ThemeStyle) -> some View {
        inputView
        .themeColor(background: .layer6)
        .cornerRadius(12)
    }

    private func createBottomView(parentStyle: ThemeStyle) -> some View {
        VStack {
            Spacer(minLength: 40)
            HStack {
                let size = showingUsdc ? size : usdcSize
                Text(size ?? "")
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textSecondary)

                Spacer()

                HStack {
                    let trailingText = showingUsdc ? tokenSymbol : "USD"
                    Text(trailingText ?? "")
                        .themeFont(fontSize: .smaller)
                    PlatformIconViewModel(type: .asset(name: "action_switch", bundle: Bundle.dydxView),
                                          size: CGSize(width: 12, height: 12),
                                          templateColor: .textSecondary)
                    .createView()
                }
                .onTapGesture { [weak self] in
                    PlatformView.hideKeyboard()
                    self?.showingUsdc = !(self?.showingUsdc ?? false)
                }
            }
        }
        .padding(12)
        .makeInput()
    }
}

#if DEBUG
struct dydxTradeInputSizeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputSizeViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputSizeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputSizeViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
