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
    @Published public var sizeItem = dydxSimpleUITradeInputSizeItemViewModel()
    @Published public var usdSizeItem = dydxSimpleUITradeInputSizeItemViewModel()

    @Published public var showingUsdc: Bool = true {
        didSet {
            if showingUsdc {
                sizeItem.isFocused = false
                DispatchQueue.main.async { [weak self] in
                    self?.usdSizeItem.isFocused = true
                }
            } else {
                usdSizeItem.isFocused = false
                DispatchQueue.main.async {  [weak self] in
                    self?.sizeItem.isFocused = true
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
                    let offset = self.showingUsdc ? 0.0 : -animationBoxHeight
                    VStack(alignment: .leading, spacing: 0) {
                        self.usdSizeItem.createView(parentStyle: style)
                        self.sizeItem.createView(parentStyle: style)
                    }
                    .offset(x: 0, y: offset)
                }
                .frame(height: animationBoxHeight, alignment: .top)
                .clipped()

                let content = PlatformIconViewModel(type: .asset(name: "icon_swap_vertical", bundle: .dydxView),
                                                    clip: .circle(background: .layer4, spacing: 16, borderColor: .textTertiary),
                                                    templateColor: .textSecondary)
                PlatformButtonViewModel(content: content,
                                        type: .iconType) { [weak self] in
                    withAnimation(Animation.easeInOut) {
                        self?.showingUsdc.toggle()
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
