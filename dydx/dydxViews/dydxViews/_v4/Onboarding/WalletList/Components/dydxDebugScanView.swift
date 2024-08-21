//
//  dydxDebugScanView.swift
//  dydxViews
//
//  Created by Rui Huang on 3/1/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxDebugScanViewModel: dydxWalletListItemView {
    @Published public var text: String?

    public init() { }

    public static var previewValue: dydxDebugScanViewModel {
        let vm = dydxDebugScanViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = Text("Scan me in Wallet")
            let trailing = Text("Debug only")
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textTertiary)
            let image = PlatformIconViewModel(type: .asset(name: "icon_qrscan", bundle: Bundle.dydxView),
                                     size: CGSize(width: 36, height: 36))

            return self.createItemView(main: main.wrappedViewModel,
                                  trailing: trailing.wrappedViewModel,
                                  image: image,
                                  style: style)
        }
    }
}

#if DEBUG
struct dydxDebugScanView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxDebugScanViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxDebugScanView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxDebugScanViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
