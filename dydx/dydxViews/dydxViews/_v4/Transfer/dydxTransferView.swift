//
//  dydxTransferView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/24/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferViewModel: PlatformViewModel {
    @Published public var sections = dydxTransferSectionsViewModel()
    @Published public var faucet = dydxTransferFaucetViewModel()
    @Published public var deposit: dydxTransferDepositViewModel? = dydxTransferDepositViewModel()
    @Published public var withdrawal: dydxTransferWithdrawalViewModel? = dydxTransferWithdrawalViewModel()
    @Published public var transferOut: dydxTransferOutViewModel? = dydxTransferOutViewModel()
    @Published public var sectionSelection: dydxTransferSectionsViewModel.TransferSection = .deposit

    public init() { }

    public static var previewValue: dydxTransferViewModel {
        let vm = dydxTransferViewModel()
        vm.sections = .previewValue
        vm.deposit = .previewValue
        vm.withdrawal = .previewValue
        vm.transferOut = .previewValue
        vm.faucet = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let topPadding = 40.0
            let view =
                ScrollView(showsIndicators: false) {
                    VStack {
                        self.sections.createView(parentStyle: style)

                        switch self.sectionSelection {
                        case .faucet:
                            self.faucet
                                .createView(parentStyle: style)

                        case .deposit:
                            self.deposit?
                                .createView(parentStyle: style)

                        case .withdraw:
                            self.withdrawal?
                                .createView(parentStyle: style)

                        case .transferOut:
                            self.transferOut?
                                .createView(parentStyle: style)
                        }

                        Spacer()
                    }
                    .frame(minHeight: UIScreen.main.bounds.size.height - topPadding - (self.safeAreaInsets?.top ?? 0) - (self.safeAreaInsets?.bottom ?? 0))
                }
                .keyboardObserving()
                .keyboardAccessory(background: .layer3, parentStyle: style)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding([.leading, .trailing])
                .padding(.top, topPadding)
                .padding(.bottom, self.safeAreaInsets?.bottom)
                .themeColor(background: .layer3)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxTransferView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
