//
//  dydxOnboardScanView.swift
//  dydxViews
//
//  Created by Rui Huang on 3/13/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxOnboardScanViewModel: PlatformViewModel {
    @Published public var enableCameraAction: (() -> Void)?
    @Published public var backAction: (() -> Void)?
    @Published public var cameraPermitted = true
    @Published public var cameraPreview: UIView?
    @Published public var showingError = false

    public init() { }

    public static var previewValue: dydxOnboardScanViewModel {
        let vm = dydxOnboardScanViewModel()
        vm.cameraPermitted = true
        vm.showingError = true
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 16) {
                HStack {
                    let buttonContent = PlatformIconViewModel(type: .system(name: "chevron.left"), size: CGSize(width: 16, height: 16))
                    PlatformButtonViewModel(content: buttonContent, type: .iconType) { [weak self] in
                        self?.backAction?()
                    }
                    .createView(parentStyle: style)

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.SCAN_QR_CODE"))
                        .themeFont(fontType: .bold, fontSize: .largest)
                }
                .leftAligned()

                Text(DataLocalizer.localize(path: "APP.ONBOARDING.SCAN_QR_CODE_DESC"))
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textTertiary)

                ZStack {
                    self.createCameraView(parentStyle: style)
                    if self.cameraPermitted == false {
                        self.createPermissionView(parentStyle: style)
                    }
                }
                .frame(height: UIScreen.main.bounds.width)

                Spacer()
            }
                .padding([.leading, .trailing])
                .padding(.top, 40)
                .themeColor(background: .layer3)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createCameraView(parentStyle: ThemeStyle) -> some View {
        ZStack {
            cameraPreview?.swiftUIView

            if showingError {
                VStack {
                    Spacer()

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.SCAN_QR_CODE_ERROR"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .themeGradient(background: .layer5, gradientColor: .clear)
                }
            }
        }
        .animation(.default)
    }

    private func createPermissionView(parentStyle: ThemeStyle) -> some View {
        VStack(spacing: 16) {
            Text(DataLocalizer.localize(path: "APP.CAMERA.ALLOW_ACCESS"))
                .multilineTextAlignment(.center)
                .themeFont(fontSize: .large)

            Text(DataLocalizer.localize(path: "APP.CAMERA.ENABLE_CAMERA_TO_SCAN"))
                .multilineTextAlignment(.center)
                .themeFont(fontSize: .small)

            Image("image_camera_permission", bundle: Bundle.dydxView)
                .padding(.vertical, 16)

            let buttonContent = Text(DataLocalizer.localize(path: "APP.CAMERA.ENABLE_CAMERA"))
                .themeFont(fontSize: .medium)
                .wrappedViewModel
            PlatformButtonViewModel(content: buttonContent, type: .small) { [weak self] in
                 self?.enableCameraAction?()
            }
            .createView(parentStyle: parentStyle)
        }
        .centerAligned()
    }
}

#if DEBUG
struct dydxOnboardScanView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardScanViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxOnboardScanView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxOnboardScanViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
