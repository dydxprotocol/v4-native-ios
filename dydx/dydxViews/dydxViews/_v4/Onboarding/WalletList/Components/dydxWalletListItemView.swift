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

    func createItemView(main: PlatformViewModel, trailing: PlatformViewModel, image: PlatformIconViewModel, style: ThemeStyle) -> AnyView {
        AnyView(
           Group {
               PlatformTableViewCellViewModel(leading: PlatformView.nilViewModel,
                                              logo: image,
                                              main: main,
                                              trailing: trailing)
                   .createView(parentStyle: style)
                   .frame(width: UIScreen.main.bounds.width - 32, height: 64)
                   .themeColor(background: .layer5)
                   .cornerRadius(16)
           }
           .frame(maxWidth: .infinity)
           .frame(height: 64)
           .onTapGesture { [weak self] in
               self?.onTap?()
           }
       )
    }
}
