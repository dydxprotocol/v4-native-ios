//
//  dydxMarketTpSlGroupView.swift
//  dydxUI
//
//  Created by Rui Huang on 16/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketTpSlGroupViewModel: PlatformViewModel {
    @Published public var takeProfitStatusViewModel: dydxTakeProfitStopLossStatusViewModel?
    @Published public var stopLossStatusViewModel: dydxTakeProfitStopLossStatusViewModel?
    @Published public var takeProfitStopLossAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxMarketTpSlGroupViewModel {
        let vm = dydxMarketTpSlGroupViewModel()
        vm.takeProfitStatusViewModel = .previewValue
        vm.stopLossStatusViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view =  HStack(spacing: 12) {
                if self.takeProfitStatusViewModel != nil {
                    self.takeProfitStatusViewModel?.createView(parentStyle: style)
                } else {
                    self.createAddButton(label: DataLocalizer.localize(path: "APP.TRADE.TAKE_PROFIT"),
                                         style: style)
                }

                if self.stopLossStatusViewModel != nil {
                    self.stopLossStatusViewModel?.createView(parentStyle: parentStyle)
                } else {
                    self.createAddButton(label: DataLocalizer.localize(path: "APP.TRADE.STOP_LOSS"),
                                         style: style)
                }
            }
                .frame(maxHeight: .infinity)

            return AnyView(view)
        }
    }

    private func createAddButton(label: String, style: ThemeStyle) -> some View {
        let content = HStack {
            Text(label)
                .multilineTextAlignment(.leading)
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .frame(maxWidth: 60)

            Spacer()

            PlatformIconViewModel(type: .system(name: "plus"),
                                  size: CGSize(width: 14, height: 14),
                                  templateColor: .textSecondary)
            .createView(parentStyle: style)
            .frame(width: 24, height: 24)
            .themeColor(background: .layer5)
            .clipShape(Circle())
        }
            .padding(8)
            .themeColor(background: .layer3)
            .cornerRadius(10, corners: .allCorners)
            .wrappedViewModel

        return PlatformButtonViewModel(content: content, type: .iconType) { [weak self] in
            self?.takeProfitStopLossAction?()
        }
        .createView(parentStyle: style)
    }
}

#if DEBUG
struct dydxMarketTpSlGroupView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTpSlGroupViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketTpSlGroupView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTpSlGroupViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
