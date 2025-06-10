//
//  dydxSimpleUIMarketsView.swift
//  dydxUI
//
//  Created by Rui Huang on 17/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketsViewModel: PlatformViewModel {
    @Published public var marketList: dydxSimpleUIMarketListViewModel?
    @Published public var positionList: dydxSimpleUIPositionListViewModel?
    @Published public var keyboardUp: Bool = false
    @Published public var portfolio: dydxSimpleUIPortfolioViewModel?
    @Published public var header: dydxSimpleUIMarketsHeaderViewModel?
    @Published public var hasPosition: Bool = false
    @Published public var marketSort: dydxSimpleUIMarketSortViewModel?
    @Published public var positionsToggle: dydxSimpleUIPositionsToggleViewModel?

    @Published public var searchText: String = ""
    private lazy var searchTextBinding = Binding(
        get: {
            self.searchText
        },
        set: {
            self.searchText = $0
        }
    )

    @Published public var searchAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketsViewModel {
        let vm = dydxSimpleUIMarketsViewModel()
        vm.marketList = .previewValue
        vm.positionList = .previewValue
        vm.portfolio = .previewValue
        vm.header = .previewValue
        vm.marketSort = .previewValue
        vm.positionsToggle = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let bottomPadding: CGFloat
            if keyboardUp {
                bottomPadding = 16
            } else {
                bottomPadding = max((self.safeAreaInsets?.bottom ?? 0), 16)
            }

            let view = VStack(spacing: 8) {
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(pinnedViews: [.sectionHeaders]) {
                            if self.keyboardUp == false {
                                Section {
                                    ZStack(alignment: .top) {
                                        self.header?.createView(parentStyle: style)
                                            .padding(.top, 16)
                                            .padding(.horizontal, 16)

                                        self.portfolio?.createView(parentStyle: style)
                                            .frame(height: 240)
                                            .padding(.bottom, 8)
                                    }
                                }
                            }

                            DividerModel().createView(parentStyle: style)

                            if self.hasPosition {
                                let toggleView = AnyView(self.positionsToggle?.createView(parentStyle: style))
                                let header = self.createHeader(text: DataLocalizer.localize(path: "APP.GENERAL.YOUR_POSITIONS"), rightAccessory: toggleView)
                                Section(header: header) {
                                    self.positionList?.createView(parentStyle: style)
                                }
                            }

                            let sortView = AnyView(self.marketSort?.createView(parentStyle: style))
                            let marketHeader = self.createHeader(text: DataLocalizer.localize(path: "APP.GENERAL.MARKETS"),
                                                                 rightAccessory: sortView)
                            Section(header: marketHeader) {
                                self.marketList?.createView(parentStyle: style)

                                Spacer(minLength: 96)
                            }
                        }
                    }
                    .clipped()      // prevent blending into status bar

                    SearchBoxModel(searchText: "", focusedOnAppear: false, enabled: false)
                        .createView(parentStyle: style)
                        .onTapGesture { [weak self]  in
                            self?.searchAction?()
                        }
                        .padding(.top, 32)
                        .padding(.bottom, bottomPadding)
                        .frame(maxWidth: .infinity)
                        .background(SearchBoxModel.bottomBlendGradiant)
                }
                .keyboardObserving()
            }
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer1)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createHeader(text: String, rightAccessory: AnyView? = nil) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .themeFont(fontType: .plus, fontSize: .medium)
                .themeColor(foreground: .textPrimary)
                .leftAligned()

            Spacer()

            rightAccessory
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .themeColor(background: .layer1)
    }
}

#if DEBUG
struct dydxSimpleUIMarketsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
