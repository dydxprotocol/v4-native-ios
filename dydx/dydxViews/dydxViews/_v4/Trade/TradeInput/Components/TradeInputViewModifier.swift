//
//  TradeInputViewModifier.swift
//  dydxViews
//
//  Created by Rui Huang on 1/17/23.
//

import Foundation
import SwiftUI
import PlatformUI

public extension View {
    func makeInput(withBorder: Bool = true) -> some View {
        modifier(TradeInputModifier(withBorder: withBorder))
    }
}

struct TradeInputModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings
    let withBorder: Bool

    func body(content: Content) -> some View {
        if withBorder {
            content
                .themeColor(background: .layer4)
                .borderAndClip(style: .cornerRadius(12), borderColor: .borderDefault, lineWidth: 1)
        } else {
            content
                .themeColor(background: .layer3)
                .cornerRadius(12, corners: .allCorners)
        }
    }
}
