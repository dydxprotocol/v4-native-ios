//
//  dydxDepositView.swift
//  dydxUI
//
//  Created by Rui Huang on 05/08/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxDepositViewModel: PlatformViewModel {
    public enum Mode {
        case instant
        case turnkey
    }

    @Published public var instant: dydxInstantDepositViewModel?
    @Published public var turnkey: dydxTurnkeyDepositViewModel?
    @Published public var mode: Mode = .instant

    public init() { }

    public static var previewValue: dydxDepositViewModel {
        let vm = dydxDepositViewModel()
        vm.instant = .previewValue
        vm.turnkey = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = Group {
                switch self.mode {
                case .instant:
                    self.instant?.createView(parentStyle: style)
                case .turnkey:
                    self.turnkey?.createView(parentStyle: style)
                }
            }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxDepositView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxDepositView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
