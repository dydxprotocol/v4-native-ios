//
//  dydxOnboardConnectView.swift
//  dydxViews
//
//  Created by Rui Huang on 3/1/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxOnboardConnectViewModel: PlatformViewModel {
    @Published public var steps = [PlatformViewModel]()
    @Published public var ctaAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxOnboardConnectViewModel {
        let vm = dydxOnboardConnectViewModel()
        vm.steps = [
            ProgressStepViewModel.previewValue,
            ProgressStepViewModel.previewValue
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 16) {

                VStack(alignment: .leading, spacing: 8) {
                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.LINK_WALLET"))
                        .themeFont(fontSize: .largest)

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.TWO_SIGNATURE_REQUESTS"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                .leftAligned()

                VStack(spacing: 8) {
                    ForEach(self.steps, id: \.id) { step in
                        step.createView(parentStyle: style)
                    }
                }

                let buttonContent =
                Text(DataLocalizer.localize(path: "APP.ONBOARDING.LINK_WALLET"))
                    .wrappedViewModel
                PlatformButtonViewModel(content: buttonContent) { [weak self] in
                    self?.ctaAction?()
                }
                .createView(parentStyle: style)

                Spacer()
            }
                .padding([.leading, .trailing])
                .themeColor(background: .layer3)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxOnboardConnectView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardConnectViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxOnboardConnectView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardConnectViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
