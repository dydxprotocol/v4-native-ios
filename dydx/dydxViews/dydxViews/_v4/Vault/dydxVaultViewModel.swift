//
//  dydxVaultViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 7/30/24.
//

import Foundation
import SwiftUI
import PlatformUI

public class dydxVaultViewModel: PlatformViewModel {
    @Published public var text: String?

    public init() { }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return AnyView(dydxVaultView(viewModel: self)).wrappedInAnyView()
        }
    }
}

private struct dydxVaultView: View {
    @ObservedObject var viewModel: dydxVaultViewModel

    var body: some View {
        Text(viewModel.text ?? "test")
            .themeColor(foreground: .colorWhite)
    }
}
