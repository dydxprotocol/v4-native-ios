//
//  dydxClosePositionInputView.swift
//  dydxViews
//
//  Created by John Huang on 2/14/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import PlatformUI
import SwiftUI
import Utilities
import Introspect

public class dydxClosePositionInputViewModel: PlatformViewModel {

    @Published public var headerViewModel: dydxClosePositionHeaderViewModel? = dydxClosePositionHeaderViewModel()
    @Published public var editViewModel: dydxClosePositionInputEditViewModel? = dydxClosePositionInputEditViewModel()
    @Published public var orderbookViewModel: dydxOrderbookViewModel? = dydxOrderbookViewModel()
    @Published public var ctaButtonViewModel: dydxTradeInputCtaButtonViewModel? = dydxTradeInputCtaButtonViewModel()
    @Published public var validationViewModel: dydxValidationViewModel? = dydxValidationViewModel()
    @Published public var group: dydxOrderbookGroupViewModel? = dydxOrderbookGroupViewModel()

    public init() {}

    public static var previewValue: dydxClosePositionInputViewModel {
        let vm = dydxClosePositionInputViewModel()
        vm.headerViewModel = .previewValue
        vm.editViewModel = .previewValue
        vm.orderbookViewModel = .previewValue
        vm.ctaButtonViewModel = .previewValue
        vm.validationViewModel = .previewValue
        vm.group = .previewValue
        return vm
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                    VStack(spacing: 0) {
                        self.headerViewModel?.createView(parentStyle: style)
                            .padding(.top, 40)

                        HStack(spacing: 16) {
                            VStack {
                                self.group?.createView(parentStyle: style)
                                self.orderbookViewModel?.createView(parentStyle: style)
                                Spacer()
                            }
                                .frame(minWidth: 0, maxWidth: .infinity)

                            self.editViewModel?.createView(parentStyle: style)
                                .frame(minWidth: 0, maxWidth: .infinity)
                        }
                        .frame(height: 230)

                        Spacer()
                    }
                    .frame(height: 320)

                    Spacer()

                    VStack(spacing: -8) {
                        VStack {
                            self.validationViewModel?.createView(parentStyle: style)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .themeColor(background: .layer0)
                        .cornerRadius(12, corners: [.topLeft, .topRight])

                        self.ctaButtonViewModel?.createView(parentStyle: style)
                    }
                }
                .padding([.leading, .trailing])
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer3)
                .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxClosePositionInputViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxClosePositionInputViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}

struct dydxClosePositionInputViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxClosePositionInputViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}
#endif
