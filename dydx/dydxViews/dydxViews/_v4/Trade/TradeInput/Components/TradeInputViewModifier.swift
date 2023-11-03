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
    func makeInput() -> some View {
        modifier(TradeInputModifier())
    }
}

struct TradeInputModifier: ViewModifier {
    @EnvironmentObject var themeSettings: ThemeSettings

    func body(content: Content) -> some View {
        content
            .themeColor(background: .layer4)
            .cornerRadius(12)
    }
}
