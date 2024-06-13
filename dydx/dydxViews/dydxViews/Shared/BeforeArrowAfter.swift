//
//  BeforeArrowAfter.swift
//  dydxViews
//
//  Created by Rui Huang on 10/18/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public protocol BeforeArrowAfterModelOrdering {
    var changeDirection: (() -> ComparisonResult) { get set }
}

public class BeforeArrowAfterModel<VM: PlatformViewModeling>: PlatformViewModel, BeforeArrowAfterModelOrdering {
    public var changeDirection: (() -> ComparisonResult) = {
        .orderedSame
    }

    @Published public var before: VM?
    @Published public var after: VM?

    public init() { }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let templateColor: ThemeColor.SemanticColor
            switch self.changeDirection() {
            case .orderedSame:
                templateColor = .textSecondary
            case .orderedAscending:
                templateColor = ThemeSettings.positiveColor
            case .orderedDescending:
                templateColor = ThemeSettings.negativeColor
            }
            let arrow = PlatformIconViewModel(type: .asset(name: "icon_arrow",
                                                           bundle: Bundle.dydxView),
                                              size: CGSize(width: 16, height: 12),
                                              templateColor: templateColor)
            return AnyView(
                HStack(spacing: 4) {
                    self.before?
                        .createView(parentStyle: style, styleKey: nil)

                    if let after = self.after {
                        if self.before != nil {
                            arrow.createView(parentStyle: style)
                        }

                        after
                            .createView(parentStyle: style.themeColor(foreground: .textPrimary), styleKey: nil)
                    }
                }
                    .fixedSize()
            )
        }
    }
}
