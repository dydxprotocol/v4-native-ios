//
//  ColoredText.swift
//  PlatformUI
//
//  Created by Rui Huang on 11/10/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI

public class ColoredTextModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var color: ThemeColor.SemanticColor = .textSecondary
    
    public init(text: String? = nil, color: ThemeColor.SemanticColor = .textSecondary) {
        self.text = text
        self.color = color
    }
    
    public static var previewValue: ColoredTextModel = {
        let vm = ColoredTextModel()
        vm.text = "Test String"
        return vm
    }()
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Text(self.text ?? "")
                    .themeColor(foreground: self.color)
            )
        }
    }
}

#if DEBUG
struct ColoredText_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            ColoredTextModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif

