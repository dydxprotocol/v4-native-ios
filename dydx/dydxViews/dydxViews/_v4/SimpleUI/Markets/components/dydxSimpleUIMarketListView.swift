//
//  dydxSimpleUIMarketListView.swift
//  dydxUI
//
//  Created by Rui Huang on 18/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketListViewModel: PlatformViewModel {
    @Published public var markets: [dydxSimpleUIMarketViewModel]?
    @Published public var searchText: String = ""
    @Published public var cancelAction: (() -> Void)?

    private lazy var searchTextBinding = Binding(
        get: {
            self.searchText
        },
        set: {
            self.searchText = $0
        }
    )

    public init() { }

    public static var previewValue: dydxSimpleUIMarketListViewModel {
        let vm = dydxSimpleUIMarketListViewModel()
        vm.markets = [
            dydxSimpleUIMarketViewModel.previewValue,
            dydxSimpleUIMarketViewModel.previewValue
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        if self.markets?.isEmpty ?? false {
                            PlaceholderViewModel(text: DataLocalizer.localize(path: "APP.GENERAL.NO_MARKET"))
                                .createView(parentStyle: style)
                        } else {
                            ForEach(self.markets ?? [], id: \.marketId) { market in
                                market.createView(parentStyle: style)
                                if market !== self.markets?.last {
                                    DividerModel().createView(parentStyle: style)
                                }
                            }
                        }
                    }
                }

                self.createSearchBar(style: style)
            }
                .keyboardObserving()

            return AnyView(view)
        }
    }

    private func createSearchBar(style: ThemeStyle) -> some View {
        HStack(alignment: .center, spacing: 0) {
            PlatformIconViewModel(type: .asset(name: "icon_search", bundle: Bundle.dydxView),
                                  size: CGSize(width: 16, height: 16),
                                  templateColor: .textTertiary)
            .createView(parentStyle: style)
            .padding(.leading, 16)

            PlatformInputModel(value: self.searchTextBinding,
                               currentValue: self.searchText,
                               placeHolder: DataLocalizer.localize(path: "APP.GENERAL.SEARCH"),
                               keyboardType: .default,
                               focusedOnAppear: false)
            .createView(parentStyle: style)
            .frame(height: 40)
            .padding(.vertical, 2)

            if searchText.isNotEmpty {
                let closeIcon = PlatformIconViewModel(type: .asset(name: "icon_cancel", bundle: Bundle.dydxView),
                                                      clip: .circle(background: .layer3, spacing: 0, borderColor: .layer6),
                                                      size: CGSize(width: 16, height: 16),
                                                      templateColor: .textTertiary)
                PlatformButtonViewModel(content: closeIcon,
                                        type: .iconType,
                                        action: { [weak self] in
                    self?.searchText = ""
                })
                .createView(parentStyle: style)
                .padding(.trailing, 16)
            }
        }
        .themeColor(background: .layer3)
        .clipShape(Capsule())
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

#if DEBUG
struct dydxSimpleUIMarketListView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketListViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketListView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketListViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
