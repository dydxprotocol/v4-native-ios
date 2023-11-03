//
//  dydxOnboardQRCodeView.swift
//  dydxViews
//
//  Created by Rui Huang on 3/22/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import EFQRCode

public class dydxOnboardQRCodeViewModel: PlatformViewModel {
    @Published public var qrCode: String?

    public init() { }

    public static var previewValue: dydxOnboardQRCodeViewModel {
        let vm = dydxOnboardQRCodeViewModel()
        vm.qrCode = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(spacing: 16) {
                    Spacer()
                    if let qrCode = self.qrCode,
                       let cgImage = EFQRCode.generate(for: qrCode) {
                        let uiImage = UIImage(cgImage: cgImage)
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.horizontal, 32)
                     } else {
                        PlatformView.nilView
                    }
                    Text("Scan this QR code with your wallet app to connect.")
                        .themeFont(fontSize: .medium)
                        .leftAligned()
                        .padding(.horizontal, 32)
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
struct dydxOnboardQRCodeView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardQRCodeViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxOnboardQRCodeView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardQRCodeViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
