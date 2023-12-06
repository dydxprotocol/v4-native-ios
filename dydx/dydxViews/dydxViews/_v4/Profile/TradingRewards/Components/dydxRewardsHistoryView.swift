//
//  dydxRewardsHistoryView.swift
//  dydxViews
//
//  Created by Michael Maguire on 12/6/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxRewardsHistoryViewModel: dydxTitledCardViewModel {
    @Published public var filters: [TabItemViewModel.TabItemContent] = []
    @Published public var onSelectionChanged: ((Int) -> Void)?

    @Published public var items: [dydxFAQViewModel] = [] {
        didSet {
            listViewModel.items = items
        }
    }
    private let listViewModel = PlatformListViewModel()
    @Published private var filtersViewWidth: CGFloat = .zero

    public init() {
        super.init(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.REWARD_HISTORY", params: nil) ?? "",
                   verticalContentPadding: 0,
                   horizontalContentPadding: 0)
    }

    public override func createTitleAccessoryView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        let items = filters.compactMap { TabItemViewModel(value: $0, isSelected: false) }
        let selectedItems = filters.compactMap {TabItemViewModel(value: $0, isSelected: true) }
        return ScrollView(.horizontal, showsIndicators: false) {
                TabGroupModel(items: items,
                              selectedItems: selectedItems,
                              currentSelection: 0,
                              onSelectionChanged: { [weak self] index in
                    self?.onSelectionChanged?(index)
                },
                              spacing: 8)
                .createView(parentStyle: parentStyle)
                .sizeReader {[weak self] size in
                    self?.filtersViewWidth = size.width
                }
            }
        .disableBounces()
        .frame(maxWidth: filtersViewWidth, alignment: .trailing)
        .wrappedInAnyView()

    }

    public override func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        listViewModel
            .createView()
        .wrappedInAnyView()
    }

    public static var previewValue: dydxRewardsHistoryViewModel {
        let vm = dydxRewardsHistoryViewModel()
        vm.items = [.previewValue]
        return vm
    }
}

#if DEBUG
struct dydxRewardsHistoryViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxRewardsHistoryViewModel.previewValue
            .createView()
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxRewardsHistoryViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxRewardsHistoryViewModel.previewValue
            .createView()
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
