//
//  dydxMarketAssetSortView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/3/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketAssetSortViewModel: PlatformViewModel {
    @Published public var contents: [String] = []
    @Published public var onSelectionChanged: ((Int) -> Void)?

    public init() { }

    public init(contents: [String] = [], onSelectionChanged: ((Int) -> Void)? = nil) {
        self.contents = contents
        self.onSelectionChanged = onSelectionChanged
    }

    public static var previewValue: dydxMarketAssetSortViewModel = {
        let vm = dydxMarketAssetSortViewModel()
        vm.contents = ["Volume", "Gainers", "Losers", "Funding", "Name", "Price", "Price", "Price", "Price"]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items: [PlatformViewModel] = self.contents.compactMap { type in
                Text(type)
                    .themeFont(fontSize: .small)
                    .wrappedViewModel
            }
            return AnyView(
                HStack {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SORT_BY"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textPrimary)
                    ScrollViewReader { value in
                        ScrollView(.horizontal, showsIndicators: false) {
                            TabGroupModel(items: items, currentSelection: 0,
                                          unselectedStyleKey: "text_tab_group_unselected_item",
                                          selectedStyleKey: "text_tab_group_selected_item",
                                          onSelectionChanged: { [weak self] index in
                                withAnimation(Animation.easeInOut(duration: 0.05)) {
                                    value.scrollTo(index)
                                    self?.onSelectionChanged?(index)
                                }
                            })
                            .createView(parentStyle: style)
                            .animation(.default, value: self.contents)
                        }
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketAssetSortView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAssetSortViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketAssetSortView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAssetSortViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
