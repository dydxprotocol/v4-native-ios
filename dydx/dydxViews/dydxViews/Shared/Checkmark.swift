//
//  Checkmark.swift
//  dydxViews
//
//  Created by Rui Huang on 17/12/2024.
//

import PlatformUI
import SwiftUI

public extension PlatformIconViewModel {
    static var selectedCheckmark: PlatformIconViewModel {
        PlatformIconViewModel(type: .asset(name: "icon_checked", bundle: Bundle.dydxView),
                             clip: .circle(background: .colorPurple,
                                           spacing: 12,
                                           borderColor: nil),
                             size: CGSize(width: 20, height: 20),
                             templateColor: .textPrimary)
    }

    static var unselectedCheckmark: PlatformViewModel {
        Circle()
            .fill(ThemeColor.SemanticColor.layer1.color)
            .frame(width: 20, height: 20)
            .overlay(
                Circle().stroke(ThemeColor.SemanticColor.layer5.color, lineWidth: 1)
            )
            .wrappedViewModel
    }
}
