//
//  dydxSimpleUIMarketInfoView.swift
//  dydxUI
//
//  Created by Rui Huang on 26/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketInfoViewModel: PlatformViewModel {
    @Published public var header: dydxSimpleUIMarketInfoHeaderViewModel?
    @Published public var chart: dydxSimpleUIMarketCandlesViewModel?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketInfoViewModel {
        let vm = dydxSimpleUIMarketInfoViewModel()
        vm.header = .previewValue
        vm.chart = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                self.header?.createView(parentStyle: style)

                ScrollView(showsIndicators: false) {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        self.chart?.createView(parentStyle: style)

                        // for tab bar scroll adjstment overlap
                        Spacer(minLength: 128)
                    }
                    .themeColor(background: .layer2)
                }

            }
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer2)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketInfoView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketInfoViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketInfoView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketInfoViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
