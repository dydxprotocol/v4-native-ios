//
//  LeverageRisk.swift
//  dydxViews
//
//  Created by Rui Huang on 10/19/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class LeverageRiskModel: PlatformViewModel {
    public enum Level {
        case low, medium, high

        public init(marginUsage: Double) {
            if marginUsage <= 0.2 {
                self = .low
            } else if marginUsage <= 0.4 {
                self = .medium
            } else {
                self = .high
            }
        }

        public var text: String {
            switch self {
            case .low:
                return DataLocalizer.localize(path: "APP.TRADE.LOW")
            case .medium:
                return DataLocalizer.localize(path: "APP.TRADE.MEDIUM")
            case .high:
                return DataLocalizer.localize(path: "APP.TRADE.HIGH")
            }
        }

        var imageName: String {
            switch self {
            case .low:
                return "leverage_low"
            case .medium:
                return "leverage_medium"
            case .high:
                return "leverage_high"
            }
        }
    }

    public enum DisplayOption {
        case iconOnly, iconAndText
    }
    @Published public var level = Level.low
    @Published public var viewSize = 32
    @Published public var displayOption: DisplayOption = .iconAndText

    public init(level: LeverageRiskModel.Level = Level.low, viewSize: Int = 32, displayOption: DisplayOption = .iconAndText) {
        self.level = level
        self.viewSize = viewSize
        self.displayOption = displayOption
    }

    public init() { }

    public static var previewValue: LeverageRiskModel {
        let vm = LeverageRiskModel()
        vm.level = .high
        vm.viewSize = 24
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    PlatformIconViewModel(type: .asset(name: self.level.imageName, bundle: Bundle.dydxView),
                                          clip: .noClip,
                                          size: CGSize(width: self.viewSize, height: self.viewSize))
                    .createView(parentStyle: style)

                    if self.displayOption == .iconAndText {
                        Text(self.level.text)
                            .themeFont(fontSize: .small)
                            .lineLimit(1)
                    }
                }
            )
        }
    }
}

#if DEBUG
struct LeverageRisk_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return LeverageRiskModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct LeverageRisk_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return LeverageRiskModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
