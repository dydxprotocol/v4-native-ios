//
//  SizeText.swift
//  dydxViews
//
//  Created by Rui Huang on 10/19/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class SizeTextModel: PlatformViewModel {
    @Published public var size: NSNumber?
    @Published public var stepSize: String?

    public init(amount: NSNumber? = nil, stepSize: String? = nil) {
        self.size = amount
        self.stepSize = stepSize
    }

    public init() { }

    public static var previewValue: SizeTextModel {
        let vm = SizeTextModel()
        vm.size = NSNumber(value: 1234)
        vm.stepSize = "10"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let sizeText = dydxFormatter.shared.localFormatted(number: self.size, size: self.stepSize)
            return AnyView(
                Text(sizeText ?? "")
                    .themeFont(fontType: .number, fontSize: .small)
                    .lineLimit(1)
            )
        }
    }
}

#if DEBUG
struct SizeText_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SizeTextModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SizeText_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SizeTextModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
