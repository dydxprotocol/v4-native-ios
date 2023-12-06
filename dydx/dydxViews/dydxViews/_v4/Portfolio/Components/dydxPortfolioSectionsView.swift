//
//  dydxPortfolioSectionsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioSectionsViewModel: PlatformViewModel {
    @Published public var itemTitles: [String]?
    @Published public var onSelectionChanged: ((Int) -> Void)?
    @Published public var sectionIndex: Int? = 0

    public init() { }

    public static var previewValue: dydxPortfolioSectionsViewModel {
        let vm = dydxPortfolioSectionsViewModel()
        vm.itemTitles = ["Positions", "Orders", "Fills", "Funding"]
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
                Text($0)
                    .themeFont(fontType: .bold, fontSize: .largest)
                    .themeColor(foreground: .textPrimary)
                    .wrappedViewModel
            }
            return AnyView(
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        TabGroupModel(items: items,
                                      selectedItems: selectedItems,
                                      currentSelection: self.sectionIndex,
                                      onSelectionChanged: self.onSelectionChanged,
                                      spacing: 16)
                            .createView(parentStyle: style)
                            .animation(.none)
                    }
                }
                .padding(.vertical, 16)
                .themeColor(background: .layer2)
            )
        }
    }
}

#if DEBUG
struct dydxPortfolioSectionsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioSectionsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioSectionsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioSectionsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
