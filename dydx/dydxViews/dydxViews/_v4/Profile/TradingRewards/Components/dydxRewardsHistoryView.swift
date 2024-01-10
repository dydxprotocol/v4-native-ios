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
    // MARK: public properties
    @Published public var filters: [TabItemViewModel.TabItemContent] = []
    @Published public var onSelectionChanged: ((Int) -> Void)?
    @Published public var items: [dydxRewardsRewardViewModel] = []
    public var contentChanged: (() -> Void)?

    // MARK: private properties
    private static let numItemsStepSize: Int = 10
    private var visibleItems: [dydxRewardsRewardViewModel] {
        Array(items.prefix(maxItemsToDisplay))
    }
    private var hasMoreItemsToDisplay: Bool { items.count > maxItemsToDisplay }
    @Published private var maxItemsToDisplay: Int = dydxRewardsHistoryViewModel.numItemsStepSize
    @Published private var filtersViewWidth: CGFloat = .zero

    // MARK: impl

    public init() {
        super.init(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.REWARD_HISTORY", params: nil) ?? "",
                   tooltip: DataLocalizer.shared?.localize(path: "TRADE.REWARD_HISTORY.BODY", params: nil) ?? "")
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

    private let headerViewModel: PlatformViewModel = {
        PlatformViewModel { _ in
            HStack(spacing: 0) {
                Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.EVENT", params: nil) ?? "")
                    .themeFont(fontType: .text, fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
                Spacer()
                Text(DataLocalizer.shared?.localize(path: "APP.TRADING_REWARDS.TRADING_REWARD", params: nil) ?? "")
                    .themeFont(fontType: .text, fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
            }
            .wrappedInAnyView()
        }
    }()

    private var itemsListViewModel: PlatformListViewModel {
        PlatformListViewModel(items: visibleItems,
                              intraItemSeparator: false,
                              contentChanged: contentChanged)
    }

    private var viewMoreButtonViewModel: PlatformButtonViewModel<PlatformViewModel> {
        PlatformButtonViewModel(content: PlatformViewModel { _ in
            HStack(spacing: 8) {
                Text("View More")
                    .themeFont(fontType: .text, fontSize: .small)
                    .themeColor(foreground: .textSecondary)
                PlatformIconViewModel(type: .asset(name: "icon_dropdown", bundle: Bundle.dydxView),
                                                         clip: .noClip,
                                                         size: .init(width: 14, height: 8),
                                                         templateColor: .textSecondary)
                .createView()
            }
            .wrappedInAnyView()
        },
                                type: .defaultType,
                                state: .secondary,
                                action: {
            withAnimation { [weak self] in
                self?.maxItemsToDisplay += dydxRewardsHistoryViewModel.numItemsStepSize
            }
        })
    }

    public override func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        VStack(spacing: 16) {
            VStack(spacing: 10) {
                headerViewModel.createView(parentStyle: parentStyle)
                itemsListViewModel.createView(parentStyle: parentStyle)
            }
            if self.hasMoreItemsToDisplay {
                viewMoreButtonViewModel.createView(parentStyle: parentStyle)
            }
        }
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
