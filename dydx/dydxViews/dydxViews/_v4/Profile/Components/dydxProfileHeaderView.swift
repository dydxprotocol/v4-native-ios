//
//  dydxProfileHeaderView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileHeaderViewModel: PlatformViewModel {
    @Published public var dydxChainLogoUrl: URL?
    @Published public var dydxAddress: String?
    @Published public var onTapAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxProfileHeaderViewModel {
        let vm = dydxProfileHeaderViewModel()
        vm.dydxAddress = "dydx11111111111111111111111"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let icon = PlatformIconViewModel(type: self.dydxAddress != nil ? .url(url: self.dydxChainLogoUrl) : .asset(name: "hedgie_placeholder", bundle: Bundle.dydxView),
                                             size: CGSize(width: 64, height: 64))
            let main = VStack(alignment: .leading, spacing: 4) {
                Text(DataLocalizer.localize(path: "APP.V4.DYDX_ADDRESS"))
                    .themeFont(fontSize: .small)

                Text(self.dydxAddress ?? "-")
                    .themeColor(foreground: .textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            let trailing = self.dydxAddress != nil ? PlatformIconViewModel(type: .system(name: "chevron.right"), size: CGSize(width: 16, height: 16)) : PlatformView.nilViewModel
            return AnyView(
                PlatformTableViewCellViewModel(leading: icon,
                                               main: main.wrappedViewModel,
                                               trailing: trailing)
                .createView(parentStyle: style)
                .onTapGesture { [weak self] in
                    if self?.dydxAddress != nil {
                        self?.onTapAction?()
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxProfileHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileHeaderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileHeaderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
