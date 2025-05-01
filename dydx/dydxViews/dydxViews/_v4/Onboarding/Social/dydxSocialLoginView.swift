//
//  dydxSocialLoginView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/1/2025.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSocialLoginViewModel: PlatformViewModel {
    @Published public var headerView = NavHeaderModel()

    public init() { }

    public static var previewValue: dydxSocialLoginViewModel {
        let vm = dydxSocialLoginViewModel()
        vm.headerView = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                self.headerView.createView(parentStyle: style)
                
                Spacer()
            }
                .padding([.leading, .trailing])
                .themeColor(background: .layer3)
            
            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSocialLoginView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSocialLoginViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSocialLoginView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSocialLoginViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
