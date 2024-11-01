//
//  dydxVaultHistoryView.swift
//  dydxUI
//
//  Created by Rui Huang on 31/10/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxVaultHistoryViewModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var headerViewModel: NavHeaderModel? = NavHeaderModel()
    @Published public var historyItems = dydxVaultHistoryListViewModel()

    public init() { }

    public static var previewValue: dydxVaultHistoryViewModel {
        let vm = dydxVaultHistoryViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                self.headerViewModel?.createView(parentStyle: style)

                ScrollView(showsIndicators: false) {
                    self.historyItems
                        .createView(parentStyle: style)
                }
            }
                .themeColor(background: .layer3)

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxVaultHistoryView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxVaultHistoryViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxVaultHistoryView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxVaultHistoryViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
