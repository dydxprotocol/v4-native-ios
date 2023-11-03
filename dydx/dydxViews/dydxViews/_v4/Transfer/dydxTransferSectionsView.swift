//
//  dydxTransferSectionsView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/2/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferSectionsViewModel: PlatformViewModel {
    public enum TransferSection {
        case faucet, deposit, withdraw, transferOut
    }

    @Published public var itemTitles: [String]?
    @Published public var onSelectionChanged: ((Int) -> Void)?
    @Published public var sectionIndex: Int? = 0

    public init() { }

    public static var previewValue: dydxTransferSectionsViewModel {
        let vm = dydxTransferSectionsViewModel()
        vm.itemTitles = ["Faucet", "Deposit", "Withdraw"]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = self.itemTitles?.compactMap {
                Text($0)
                    .themeFont(fontType: .bold, fontSize: .largest)
                    .themeColor(foreground: .textTertiary)
                    .wrappedViewModel
            }
            let selectedItems = self.itemTitles?.compactMap {
                Text(" \($0) ")
                    .themeFont(fontType: .bold, fontSize: .largest)
                    .padding([.bottom, .top], 6)
                    .padding([.leading, .trailing], 8)
                    .themeColor(foreground: .textPrimary)
                    .themeColor(background: .layer2)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule(style: .circular)
                            .stroke(ThemeColor.SemanticColor.layer6.color, lineWidth: 1)
                    )
                    .padding(.vertical, 2)
                    .wrappedViewModel
            }
            return AnyView(
                HStack {
                    ScrollViewReader { value in
                        ScrollView(.horizontal, showsIndicators: false) {
                            TabGroupModel(items: items,
                                          selectedItems: selectedItems,
                                          currentSelection: self.sectionIndex,
                                          onSelectionChanged: { [weak self] val in
                                withAnimation(Animation.easeInOut(duration: 0.05)) {
                                    value.scrollTo(val)
                                    self?.onSelectionChanged?(val)
                                }
                            })
                            .createView(parentStyle: style)
                        }
                    }
                }
                .padding(.vertical, 16)
            )
        }
    }
}

#if DEBUG
struct dydxTransferSectionsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferSectionsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferSectionsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferSectionsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
