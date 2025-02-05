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
import dydxFormatter

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

        public var fullText: String {
            switch self {
            case .low:
                return DataLocalizer.localize(path: "APP.TRADE.LOW_RISK")
            case .medium:
                return DataLocalizer.localize(path: "APP.TRADE.MEDIUM_RISK")
            case .high:
                return DataLocalizer.localize(path: "APP.TRADE.HIGH_RISK")
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

        public var foregroundColor: ThemeColor.SemanticColor {
            switch self {
            case .low:
                return .colorGreen
            case .medium:
                return .colorYellow
            case .high:
                return .colorRed
            }
        }

        public var backgroundColor: ThemeColor.SemanticColor {
            switch self {
            case .low:
                return .colorFadedGreen
            case .medium:
                return .colorFadedYellow
            case .high:
                return .colorFadedRed
            }
        }

        public var fullTextColor: ThemeColor.SemanticColor {
            switch self {
            case .low:
                return .textTertiary
            case .medium:
                return .textTertiary
            case .high:
                return .colorRed
            }
        }

    }

    public enum DisplayOption {
        case iconOnly, iconAndText, fullText(dotted: Bool = false), percent
    }
    @Published public var level = Level.low
    @Published public var viewSize = 32
    @Published public var displayOption: DisplayOption = .iconAndText
    @Published public var marginUsage: Double = 0 {
        didSet {
            level = .init(marginUsage: marginUsage)
        }
    }

    public init(marginUsage: Double, viewSize: Int = 32, displayOption: DisplayOption = .iconAndText) {
        self.marginUsage = marginUsage
        self.level = .init(marginUsage: marginUsage)
        self.viewSize = viewSize
        self.displayOption = displayOption
    }

    public init() { }

    public static var previewValue: LeverageRiskModel {
        let vm = LeverageRiskModel()
        vm.marginUsage = 0.1
        vm.viewSize = 24
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    switch self.displayOption {
                    case .percent:
                        if let percentText = dydxFormatter.shared.percent(number: self.marginUsage, digits: 0) {
                            Text(percentText)
                                .themeFont(fontSize: .smaller)
                                .themeColor(foreground: self.level.foregroundColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(self.level.backgroundColor.color)
                                .cornerRadius(6, corners: .allCorners)
                                .themeStyle(style: style)
                                .lineLimit(1)
                        }

                    case .fullText(let dotted):
                        if dotted {
                            let attributedTitle = AttributedString(self.level.fullText)
                               .themeFont(fontSize: .small)
                               .themeColor(foreground: self.level.fullTextColor)
                            Text(attributedTitle.dottedUnderline(foreground: self.level.fullTextColor))
                                .lineLimit(1)

                        } else {
                            Text(self.level.fullText)
                                .themeFont(fontSize: .small)
                            // .themeStyle(style: style)
                                .themeColor(foreground: self.level.fullTextColor)
                                .lineLimit(1)
                        }

                    case .iconOnly:
                        PlatformIconViewModel(type: .asset(name: self.level.imageName, bundle: Bundle.dydxView),
                                              clip: .noClip,
                                              size: CGSize(width: self.viewSize, height: self.viewSize))
                        .createView(parentStyle: style)

                    case .iconAndText:
                        PlatformIconViewModel(type: .asset(name: self.level.imageName, bundle: Bundle.dydxView),
                                              clip: .noClip,
                                              size: CGSize(width: self.viewSize, height: self.viewSize))
                        .createView(parentStyle: style)

                           Text(self.level.text)
                                .themeFont(fontSize: .small)
                                .themeStyle(style: style)
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
