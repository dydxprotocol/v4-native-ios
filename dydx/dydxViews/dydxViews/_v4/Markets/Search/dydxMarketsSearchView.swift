//
//  dydxMarketsSearchView.swift
//  dydxUI
//
//  Created by Rui Huang on 15/11/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketsSearchViewModel: PlatformViewModel {
    @Published public var searchText: String = ""
    @Published public var cancelAction: (() -> Void)?
    @Published public var marketsListViewModel: dydxMarketListViewModel? = dydxMarketListViewModel()

    private lazy var searchTextBinding = Binding(
        get: {
            self.searchText
        },
        set: {
            self.searchText = $0
        }
    )

    public init() { }

    public static var previewValue: dydxMarketsSearchViewModel {
        let vm = dydxMarketsSearchViewModel()
        vm.searchText = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack {
                    self.createSearchBar(style: style)
                        .padding([.leading, .trailing])

                    if (self.marketsListViewModel?.markets.count ?? 0) > 0 {
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(pinnedViews: [.sectionHeaders]) {
                                Section {
                                    self.marketsListViewModel?
                                        .createView()
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text(DataLocalizer.localize(path: "APP.GENERAL.START_SEARCH"))
                                .themeFont(fontType: .plus, fontSize: .larger)
                                .themeColor(foreground: .textTertiary)
                            Spacer()
                        }
                        .padding(.top, 120)
                    }

                    Spacer()
                }
                .padding(.top, 32)
                .themeColor(background: .layer2)
                .makeSheet()
                .ignoresSafeArea(edges: [.bottom])
            )
        }
    }

    private func createSearchBar(style: ThemeStyle) -> AnyView {
        AnyView(
            HStack {
                PlatformInputModel(value: self.searchTextBinding,
                                   currentValue: self.searchText,
                                   placeHolder: DataLocalizer.localize(path: "APP.GENERAL.SEARCH"),
                                   keyboardType: .default,
                                   focusedOnAppear: true)
                .createView(parentStyle: style)
                .frame(height: 40)
                .padding(.vertical, 2)
                .padding(.horizontal, 12)
                .themeColor(background: .layer3)
                .clipShape(Capsule())

                PlatformButtonViewModel(content: PlatformIconViewModel(type: .asset(name: "icon_cancel", bundle: Bundle.dydxView),
                                                                       clip: .circle(background: .layer3, spacing: 24, borderColor: .layer6),
                                                                       size: CGSize(width: 42, height: 42)),
                                        type: .iconType,
                                        action: self.cancelAction ?? {})
                .createView(parentStyle: style)
            }
            .padding(.vertical, 8)
        )
    }
}

#if DEBUG
struct dydxMarketSearchView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketsSearchViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketSearchView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketsSearchViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
