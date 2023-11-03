//
//  dydxMarketFundingDurationsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/2/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketFundingDurationsViewModel: PlatformViewModel {
    @Published public var durations: [String] = []
    @Published public var onDurationChanged: ((Int) -> Void)?
    @Published public var currentDuration: Int = 0

    public init() { }

    public init(durations: [String] = [], onDurationChanged: ((Int) -> Void)? = nil, currentDuration: Int = 0) {
        self.durations = durations
        self.onDurationChanged = onDurationChanged
        self.currentDuration = currentDuration

        assert(currentDuration < durations.count)
    }

    public static var previewValue: dydxMarketFundingDurationsViewModel = {
        let vm = dydxMarketFundingDurationsViewModel()
        vm.durations = ["1 Hour", "8 Hours", "Annualized"]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = self.durations.compactMap {
                TabItemViewModel(value: .text($0), isSelected: false)
            }
            let selectedItems = self.durations.compactMap {
                TabItemViewModel(value: .text($0), isSelected: true)
            }
            return AnyView(
                TabGroupModel(items: items,
                              selectedItems: selectedItems,
                              currentSelection: self.currentDuration,
                              onSelectionChanged: self.onDurationChanged)
                    .createView(parentStyle: style)
                    .animation(.default)
            )
        }
    }
}

#if DEBUG
struct dydxMarketFundingDurationsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketFundingDurationsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketFundingDurationsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketFundingDurationsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
