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

public class dydxSimpleUITradeInputSizeViewModel: PlatformViewModel {
    @Published public var sizeItem: dydxSimpleUITradeInputSizeItemViewModel?
    @Published public var usdSizeItem: dydxSimpleUITradeInputSizeItemViewModel?

    public enum FocusState {
        case atUsdcSize, atSize, none

        var isKeyboardUp: Bool {
            return self == .atUsdcSize || self == .atSize
        }
    }

    @Published public var focusState: FocusState = .none {
        didSet {
            if focusState != oldValue {
                switch focusState {
                case .atUsdcSize:
                    sizeItem?.isFocused = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.usdSizeItem?.isFocused = true
                    }
                case .atSize:
                    usdSizeItem?.isFocused = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.sizeItem?.isFocused = true
                    }
                case .none:
                    sizeItem?.isFocused = false
                    usdSizeItem?.isFocused = false
                }
            }
        }
    }

    public static var previewValue: dydxSimpleUITradeInputSizeViewModel = {
        let vm = dydxSimpleUITradeInputSizeViewModel()
        vm.sizeItem = .previewValue
        vm.usdSizeItem = .previewValue
        return vm
    }()

    public init() { }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(alignment: .center) {
                let animationBoxHeight = dydxSimpleUITradeInputSizeItemViewModel.viewHeight
                ZStack(alignment: .leading) {
                    let offset = self.focusState == .atUsdcSize ? 0.0 : -animationBoxHeight
                    VStack(alignment: .leading, spacing: 0) {
                        self.usdSizeItem?.createView(parentStyle: style)
                        self.sizeItem?.createView(parentStyle: style)
                    }
                    .offset(x: 0, y: offset)
                }
                .frame(height: animationBoxHeight, alignment: .top)
                .clipped()
                .contentShape(Rectangle())      // needed to clip the tap events

                let content = PlatformIconViewModel(type: .asset(name: "icon_swap_vertical", bundle: .dydxView),
                                                    clip: .circle(background: .layer4, spacing: 16, borderColor: .textTertiary),
                                                    templateColor: .textSecondary)
                PlatformButtonViewModel(content: content,
                                        type: .iconType) { [weak self] in
                    withAnimation(Animation.easeInOut) {
                        switch self?.focusState {
                            case .atUsdcSize:
                            self?.focusState = .atSize
                        case .atSize:
                            self?.focusState = .atUsdcSize
                        default:
                            break
                        }
                    }
                }
                 .createView(parentStyle: style)
            }
                .padding(.horizontal, 8)

            return AnyView(view)
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
