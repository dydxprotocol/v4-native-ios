//
//  SideChange.swift
//  dydxViews
//
//  Created by Rui Huang on 10/19/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SideChangeModel: PlatformViewModel {
    @Published public var before: SideTextViewModel? = SideTextViewModel()
    @Published public var after: SideTextViewModel? = SideTextViewModel()

    public init(before: SideTextViewModel?, after: SideTextViewModel?) {
        self.before = before
        self.after = after
    }

    public init() {}

    public static var previewValue: SideChangeModel {
        let vm = SideChangeModel()
        vm.before = .previewValue
        vm.before?.side = .custom("None")
        vm.before?.coloringOption = .none
        vm.after = .previewValue
        vm.after?.side = .long
        vm.after?.coloringOption = .none
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: -6) {
                    self.before?
                        .createView(parentStyle: style
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textPrimary))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .themeColor(background: self.before?.layerColor ?? .layer3)
                        .cornerRadius(6)

                    VStack(alignment: .leading, spacing: 4) {
                        Group {
                            PlatformIconViewModel(type: .asset(name: "icon_side_change", bundle: Bundle.dydxView), size: CGSize(width: 12, height: 12))
                                .createView(parentStyle: style)
                                .padding(.top, 20)
                                .padding(.leading, 10)

                            self.after?
                                .createView(parentStyle: style
                                    .themeFont(fontSize: .small)
                                    .themeColor(foreground: .textPrimary))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .themeColor(background: self.after?.layerColor ?? .layer3)
                                .cornerRadius(6)
                        }
                    }
                }
            )
        }
    }
}

#if DEBUG
struct SideChange_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SideChangeModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SideChange_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SideChangeModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
