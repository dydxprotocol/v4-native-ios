//
//  dydxFeesStuctureView.swift
//  dydxUI
//
//  Created by Rui Huang on 10/2/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxFeesStuctureViewModel: PlatformViewModel {
    @Published public var headerViewModel: NavHeaderModel? = NavHeaderModel()
    @Published public var feesViewModel: dydxPortfolioFeesViewModel? = dydxPortfolioFeesViewModel()

    public init() { }

    public static var previewValue: dydxFeesStuctureViewModel {
        let vm = dydxFeesStuctureViewModel()
        vm.feesViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                self.headerViewModel?.createView(parentStyle: style)
                self.feesViewModel?.createView(parentStyle: style)
                Spacer()
            }
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer2)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxFeesStuctureView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxFeesStuctureViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxFeesStuctureView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxFeesStuctureViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
