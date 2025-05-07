//
//  dydxWalletListItemView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/28/23.
//

import SwiftUI
import PlatformUI
import Utilities

open class dydxWalletListItemView: PlatformViewModel {
    @Published public var onTap: (() -> Void)?
    @Published public var isInstall: Bool = true

    func createItemView(main: PlatformViewModel, trailing: PlatformViewModel?, image: PlatformIconViewModel?, style: ThemeStyle) -> AnyView {
        AnyView(
            Button(action: { [weak self] in
                self?.onTap?()
            }, label: {
                Group {
                    PlatformTableViewCellViewModel(leading: PlatformView.nilViewModel,
                                                   logo: image,
                                                   main: main,
                                                   trailing: trailing)
                        .createView(parentStyle: style)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 56)
                        .themeColor(background: .layer3)
                        .cornerRadius(16)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            })
       )
    }

    func createInstallLogo(style: ThemeStyle) -> some View {
        HStack(spacing: 4) {
            Text(DataLocalizer.localize(path: "APP.GENERAL.INSTALL"))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .small)
            PlatformIconViewModel(type: .asset(name: "icon_external_link", bundle: Bundle.dydxView),
                                  size: CGSize(width: 14, height: 14),
                                  templateColor: .textTertiary)
            .createView(parentStyle: style)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .themeColor(background: .layer4)
        .cornerRadius(8, corners: .allCorners)
    }

    func createOptionIcon(style: ThemeStyle, icon: String, templateColor: ThemeColor.SemanticColor? = nil) -> some View {
        ZStack {
            Rectangle()
                .frame(width: 34, height: 34)
                .themeColor(foreground: .layer3)
                .clipShape(.circle)

            PlatformIconViewModel(type: .asset(name: icon, bundle: Bundle.dydxView),
                                  clip: .circle(background: .layer2, spacing: 14),
                                  size: CGSize(width: 30, height: 30),
                                  templateColor: templateColor)
            .createView(parentStyle: style)
        }
    }
}
