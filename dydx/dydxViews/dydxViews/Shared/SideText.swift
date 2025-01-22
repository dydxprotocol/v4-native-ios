//
//  SideText.swift
//  dydxViews
//
//  Created by Rui Huang on 8/25/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SideTextViewModel: PlatformViewModel, Hashable {

    public enum ColoringOption {
        case none
        case colored
        case withBackground
    }

    public enum Side: Hashable {
        case long, short, buy, sell
        case none
        case custom(String)

        public var text: String {
            switch self {
            case .long:
                return DataLocalizer.localize(path: "APP.GENERAL.LONG_POSITION_SHORT", params: nil)
            case .short:
                return DataLocalizer.localize(path: "APP.GENERAL.SHORT_POSITION_SHORT", params: nil)
            case .buy:
                return DataLocalizer.localize(path: "APP.GENERAL.BUY", params: nil)
            case .sell:
                return DataLocalizer.localize(path: "APP.GENERAL.SELL", params: nil)
            case .none:
                return DataLocalizer.localize(path: "APP.GENERAL.NONE", params: nil)
            case .custom(let text):
                return text
            }
        }

        var styleKey: String {
            switch self {
            case .long, .buy:
                return ThemeSettings.positiveSideStyleKey
            case .short, .sell:
                return ThemeSettings.negativeSideStyleKey
            case .custom, .none:
                return ""
            }
        }

        var color: ThemeColor.SemanticColor {
            switch self {
            case .long, .buy:
                return ThemeSettings.positiveColor
            case .short, .sell:
                return ThemeSettings.negativeColor
            case .custom, .none:
                return ThemeColor.SemanticColor.textPrimary
            }
        }

        public init(positionSide: AppPositionSide) {
            switch positionSide {
            case .LONG:
                self = .long
            case .SHORT:
                self = .short
            case .unknown:
                self = .none
            }
        }

        public static func == (lhs: Side, rhs: Side) -> Bool {
            lhs.text == rhs.text
        }
    }

    @Published public var side: Side = .custom("")
    @Published public var coloringOption: ColoringOption = .colored

    public init(side: SideTextViewModel.Side = .custom(""), coloringOption: SideTextViewModel.ColoringOption = .colored) {
        self.side = side
        self.coloringOption = coloringOption
    }

    public static var previewValue: SideTextViewModel {
        let vm = SideTextViewModel()
        vm.side = .sell
        vm.coloringOption = .withBackground
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Group {
                    switch self.coloringOption {
                    case .none:
                        Text(self.side.text)
                    case .colored:
                        Text(self.side.text)
                            .themeStyle(styleKey: self.side.styleKey, parentStyle: style)
                    case .withBackground:
                        Text(self.side.text)
                            .themeStyle(styleKey: self.side.styleKey, parentStyle: style)
                            .padding(4)
                            .background(self.layerColor.color.opacity(0.3))
                            .cornerRadius(4, corners: .allCorners)
                    }
                }
                .themeStyle(style: style)
            )
        }
    }

    public static func == (lhs: SideTextViewModel, rhs: SideTextViewModel) -> Bool {
        lhs.side == rhs.side && lhs.coloringOption == rhs.coloringOption
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(side)
        hasher.combine(coloringOption)
    }

    public var layerColor: ThemeColor.SemanticColor {
        switch side {
        case .buy, .long:
            return ThemeSettings.positiveColorLayer
        case .sell, .short:
            return ThemeSettings.negativeColorLayer
        default:
            return .layer6
        }
    }
}

#if DEBUG
struct SideTextViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SideTextViewModel.previewValue
            .createView()
            .previewLayout(.sizeThatFits)
    }
}

struct SideTextViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return TokenTextViewModel.previewValue
            .createView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
