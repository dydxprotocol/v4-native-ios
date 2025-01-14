//
//  dydxSimpleUIPositionListView.swift
//  dydxUI
//
//  Created by Rui Huang on 13/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIPositionListViewModel: PlatformViewModel {
    @Published public var positions: [dydxSimpleUIMarketViewModel]?

    public init() { }

    public static var previewValue: dydxSimpleUIPositionListViewModel {
        let vm = dydxSimpleUIPositionListViewModel()
        vm.positions = [
            dydxSimpleUIMarketViewModel.previewValue,
            dydxSimpleUIMarketViewModel.previewValue
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = ForEach(self.positions ?? [], id: \.marketId) { market in
                market.createView(parentStyle: style)
            }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUIPositionListView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIPositionListViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIPositionListView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIPositionListViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
