//
//  dydxSimpleUIMarketSearchView.swift
//  dydxUI
//
//  Created by Rui Huang on 15/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxSimpleUIMarketSearchViewModel: PlatformViewModel {
    public enum ScrollAction {
        case none
        case toTop
    }

    @Published public var marketList: dydxSimpleUIMarketListViewModel?
    @Published public var onTextChanged: ((String) -> Void)?
    @Published public var keyboardUp: Bool = false
    @Published public var marketSort: dydxSimpleUIMarketSortViewModel?
    @Published public var filter = dydxMarketAssetFilterViewModel()

    @Published public var scrollAction: ScrollAction = .none
    @Published public var searchText: String = ""
    @Published public var showCount = false

    private static let topId = UUID().uuidString

    public init() { }

    public static var previewValue: dydxSimpleUIMarketSearchViewModel {
        let vm = dydxSimpleUIMarketSearchViewModel()
        vm.marketList = .previewValue
        vm.marketSort = .previewValue
        vm.filter = .previewValue
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

            let headerText: String
            if self.showCount {
                let marketsCount = self.marketList?.markets?.count ?? 0
                let countString = dydxFormatter.shared.localFormatted(number: Double(marketsCount) * 1.0, digits: 0) ?? "0"
                headerText = DataLocalizer.localize(path: "APP.GENERAL.MARKETS_FOUND", params: ["COUNT": countString])
            } else {
                headerText = DataLocalizer.localize(path: "APP.GENERAL.MARKETS")
            }

            let view = ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(pinnedViews: [.sectionHeaders]) {
                                Rectangle()
                                    .frame(height: 4)
                                    .themeColor(foreground: .layer1)
                                    .id(Self.topId)

                                let sortView = AnyView(self.marketSort?.createView(parentStyle: style))
                                let marketHeader = VStack {
                                    self.createHeader(text: headerText,
                                                      rightAccessory: sortView)
                                    self.filter.createView(parentStyle: style)
                                        .padding(.leading, 16)
                                }
                                    .padding(.bottom, 8)
                                    .themeColor(background: .layer1)

                                Section(header: marketHeader) {
                                    self.marketList?.createView(parentStyle: style)

                                    Spacer(minLength: 96)
                                }
                                .onChange(of: self.scrollAction) { newValue in
                                    if newValue == .toTop {
                                        withAnimation {
                                            proxy.scrollTo(Self.topId, anchor: .top)
                                        }
                                    }
                                    self.scrollAction = .none
                                }
                                .onAppear {
                                    self.scrollAction = .none
                                }
                            }
                        }
                    }
                    .clipped()      // prevent blending into status bar
                }

                SearchBoxModel(searchText: self.searchText, focusedOnAppear: true, onEditingChanged: { [weak self] focused in
                    self?.keyboardUp = focused
                }, onTextChanged: { [weak self] text in
                    self?.onTextChanged?(text)
                })
                .createView(parentStyle: style)
                .padding(.top, 32)
                .padding(.bottom, bottomPadding)
                .frame(maxWidth: .infinity)
                .background(SearchBoxModel.bottomBlendGradiant)
            }
                .keyboardObserving()
                .padding(.top, 8)
                .themeColor(background: .layer1)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createHeader(text: String, rightAccessory: AnyView? = nil) -> some View {
        HStack(spacing: 0) {
            Text(text)
                .themeFont(fontType: .plus)
                .themeColor(foreground: .textPrimary)
                .leftAligned()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

            Spacer()

            rightAccessory?.padding(.trailing, 16)
        }
        .themeColor(background: .layer1)
    }
}

#if DEBUG
struct dydxSimpleUIMarketSearchView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketSearchViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketSearchView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketSearchViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
