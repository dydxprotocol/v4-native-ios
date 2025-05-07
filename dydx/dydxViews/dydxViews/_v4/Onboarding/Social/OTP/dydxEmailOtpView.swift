//
//  dydxEmailOtpView.swift
//  dydxUI
//
//  Created by Rui Huang on 06/05/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxEmailOtpViewModel: PlatformViewModel {
    @Published public var headerViewModel: NavHeaderModel? = NavHeaderModel()
    @Published public var resendAction: (() -> Void)?
    @Published public var onOtpChanged: ((String) -> Void)?
    @Published public var email: String?
    @Published public var otp: String = ""

    public init() { }

    public static var previewValue: dydxEmailOtpViewModel {
        let vm = dydxEmailOtpViewModel()
        vm.email = "test@example.com"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                self.headerViewModel?.createView(parentStyle: style)

                VStack {
                    PlatformIconViewModel(type: .asset(name: "icon_email_2", bundle: Bundle.dydxView),
                                          size: CGSize(width: 48, height: 48),
                                          templateColor: .textPrimary)
                    .createView(parentStyle: style)
                    .padding(.top, 48)

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.ENTER_OTP_CODE"))
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontType: .plus)

                    Text(DataLocalizer.localize(path: "APP.ONBOARDING.CHECK_EMAIL_FOR_OTP_CODE",
                                                params: ["EMAIL": self.email ?? ""]))
                    .themeFont(fontSize: .small)

                    OTPFieldViewModel(otp: self.otp, onOtpChanged: self.onOtpChanged)
                        .createView(parentStyle: style)
                        .padding(.vertical, 16)

                    HStack {
                        Text(DataLocalizer.localize(path: "APP.ONBOARDING.DID_NOT_GET_EMAIL"))

                        Button { [weak self] in
                            self?.resendAction?()
                        } label: {
                            Text(DataLocalizer.localize(path: "APP.ONBOARDING.RESEND_CODE"))
                                .themeColor(foreground: .colorPurple)
                        }
                    }
                    .themeFont(fontSize: .small)

                    PlatformIconViewModel(type: .asset(name: "logo_privy", bundle: Bundle.dydxView),
                                          size: CGSize(width: 120, height: 10),
                                          templateColor: .textPrimary)
                    .createView(parentStyle: style)
                    .padding(.top, 16)
                }
                .padding([.leading, .trailing])

                Spacer()
            }
                .themeColor(background: .layer1)

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxEmailOtpView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxEmailOtpViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxEmailOtpView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxEmailOtpViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
