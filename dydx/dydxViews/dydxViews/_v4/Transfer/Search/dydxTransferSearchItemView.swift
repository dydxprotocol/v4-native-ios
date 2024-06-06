//
//  dydxTransferSearchItemView.swift
//  dydxUI
//
//  Created by Rui Huang on 4/10/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferSearchItemViewModel: PlatformViewModel {
    @Published public var onTapAction: (() -> Void)?
    @Published public var icon: PlatformViewModel?
    @Published public var text: String?
    @Published public var tokenText: TokenTextViewModel?
    @Published public var isSelected: Bool = false

    public init() { }

    public static var previewValue: dydxTransferSearchItemViewModel {
        let vm = dydxTransferSearchItemViewModel()
        vm.icon = PlatformIconViewModel(type: .system(name: "radio"), size: CGSize(width: 24, height: 24))
        vm.text = "Text"
        vm.tokenText = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = HStack {
                Text(self.text ?? "")
                    .themeFont(fontSize: .medium)
                self.tokenText?.createView(parentStyle: style.themeFont(fontSize: .smaller))
            }

            let trailing = Group {
                if self.isSelected {
                    PlatformIconViewModel(type: .system(name: "checkmark"),
                                          size: CGSize(width: 16, height: 16))
                    .createView(parentStyle: style)
                }
            }

            return AnyView(
                PlatformTableViewCellViewModel(leading: PlatformView.nilViewModel,
                                               logo: self.icon,
                                               main: main.wrappedViewModel,
                                               trailing: trailing.wrappedViewModel)
                .createView(parentStyle: style)
                .frame(width: UIScreen.main.bounds.width - 32, height: 64)
                .themeColor(background: .layer3)
                .cornerRadius(12)
                .onTapGesture { [weak self] in
                    self?.onTapAction?()
                }
            )
        }
    }
}

#if DEBUG
struct dydxTransferSearchItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferSearchItemViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferSearchItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferSearchItemViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
