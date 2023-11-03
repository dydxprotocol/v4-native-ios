//
//  Divider.swift
//  PlatformUI
//
//  Created by Rui Huang on 10/11/22.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI

public class DividerModel: PlatformViewModel {
    public static var previewValue: DividerModel = {
        let vm = DividerModel()
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { _  in
            let overlayColor = ThemeColor.SemanticColor.layer6.color

            return AnyView(
                Divider()
                    .overlay(overlayColor)
            )
        }
    }
}

#if DEBUG
struct Divider_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            DividerModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif

