//
//  QRCodeDisplay.swift
//  dydxViews
//
//  Created by Rui Huang on 11/16/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import EFQRCode

public class QRCodeDisplayModel: PlatformViewModel {
    public enum Content {
        case code(String)
        case image(UIImage)

        var qrCodeImage: UIImage? {
            switch self {
            case .image(let image):
                return image
            case .code(let code):
                if let cgImage = EFQRCode.generate(for: code) {
                    return UIImage(cgImage: cgImage)
                }
                return nil
            }
        }
    }

    @Published public var content: Content?

    public init() { }

    public static var previewValue: QRCodeDisplayModel {
        let vm = QRCodeDisplayModel()
        vm.content = .code("test code")
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack {
                    Spacer()
                    if let uiImage = self.content?.qrCodeImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        PlatformView.nilView
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding([.top], 40)
                .themeColor(background: .layer3)
                .makeSheet(topPadding: 16)
            )
        }
    }
}

#if DEBUG
struct QRCodeDisplay_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return QRCodeDisplayModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct QRCodeDisplay_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return QRCodeDisplayModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
