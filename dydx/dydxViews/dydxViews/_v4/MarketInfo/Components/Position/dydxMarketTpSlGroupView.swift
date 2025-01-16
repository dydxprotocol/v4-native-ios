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
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            var addTakeProfitStopLossButton: AnyView?

            if let takeProfitStopLossAction = self.takeProfitStopLossAction {
                let content = AnyView(
                    HStack {
                        Spacer()
                        Text(DataLocalizer.localize(path: "APP.TRADE.ADD_TP_SL"))
                            .themeFont(fontSize: .medium)
                            .themeColor(foreground: .textSecondary)
                        Spacer()
                    }
                )

                addTakeProfitStopLossButton = PlatformButtonViewModel(content: content.wrappedViewModel, state: .secondary) {
                    takeProfitStopLossAction()
                }
                .createView(parentStyle: parentStyle)
                .wrappedInAnyView()
            }

            let view =  HStack(spacing: 10) {
                if self.takeProfitStatusViewModel != nil || self.stopLossStatusViewModel != nil {
                    HStack(spacing: 10) {
                        Group {
                            self.takeProfitStatusViewModel?.createView(parentStyle: parentStyle)
                                .frame(maxWidth: .infinity)
                            self.stopLossStatusViewModel?.createView(parentStyle: parentStyle)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxHeight: .infinity)
                    }
                } else {
                    addTakeProfitStopLossButton
                        .frame(maxWidth: .infinity)
                }
            }

            return AnyView(view)
        }
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
