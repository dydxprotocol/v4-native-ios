//
//  dydxMarketAssetFilterView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/4/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketAssetFilterViewModel: PlatformViewModel {
    @Published public var contents: [TabItemViewModel.TabItemContent] = []
    @Published public var onSelectionChanged: ((Int) -> Void)?

    public init() { }

    public init(contents: [TabItemViewModel.TabItemContent] = [], onSelectionChanged: ((Int) -> Void)? = nil) {
        self.contents = contents
        self.onSelectionChanged = onSelectionChanged
    }

    public static var previewValue: dydxMarketAssetFilterViewModel = {
        let vm = dydxMarketAssetFilterViewModel()
        vm.contents = [
            .text("All"),
            .icon(UIImage(systemName: "heart.fill") ?? UIImage()),
            .text("Layer 1"),
            .text("DeFi")
        ]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = self.contents.compactMap { TabItemViewModel(value: $0, isSelected: false) }
            let selectedItems = self.contents.compactMap {TabItemViewModel(value: $0, isSelected: true) }
            return AnyView(
                HStack {
                    ScrollViewReader { value in
                        ScrollView(.horizontal, showsIndicators: false) {
                            TabGroupModel(items: items,
                                          selectedItems: selectedItems,
                                          currentSelection: 0,
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
struct dydxMarketAssetFilterView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAssetFilterViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketAssetFilterView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAssetFilterViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
