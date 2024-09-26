//
//  dydxMarketsView.swift
//  dydxViews
//
//  Created by Rui Huang on 9/1/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketsViewModel: PlatformViewModel {
    public enum ScrollAction {
        case none
        case toTop
    }

    private static let topId = UUID().uuidString

    @Published public var header = dydxMarketsHeaderViewModel()
    @Published public var banner: dydxMarketsBannerViewModel?
    @Published public var summary = dydxMarketSummaryViewModel()
    @Published public var filter = dydxMarketAssetFilterViewModel()
    @Published public var filterFooterText: String?
    @Published public var sort = dydxMarketAssetSortViewModel()
    @Published public var marketsListViewModel: dydxMarketListViewModel? = dydxMarketListViewModel()
    @Published public var scrollAction: ScrollAction = .none

    public init() { }

    public static var previewValue: dydxMarketsViewModel = {
        let vm = dydxMarketsViewModel()
        vm.header = .previewValue
        vm.banner = .previewValue
        vm.summary = .previewValue
        vm.filter = .previewValue
        vm.sort = .previewValue
        vm.marketsListViewModel = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            let view = VStack(spacing: 0) {
                self.header.createView(parentStyle: style)
                    .padding(.horizontal, 16)

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(pinnedViews: [.sectionHeaders]) {

                            if let banner = self.banner {
                                banner
                                    .createView()
                                    .padding(.horizontal, 16)
                                    .padding(.top, 12)
                            }

                             self.summary.createView(parentStyle: style)
                                 .themeColor(background: .layer2)
                                 .zIndex(.greatestFiniteMagnitude)
                                 .padding(.horizontal, 16)

                             let header =
                             VStack(spacing: 0) {
                                 VStack(alignment: .leading, spacing: 8) {
                                     self.filter.createView(parentStyle: style)
                                         .padding(.leading, 16)
                                     if let filterFooterText = self.filterFooterText {
                                         Text(filterFooterText)
                                             .themeFont(fontType: .base, fontSize: .small)
                                             .themeColor(foreground: .textTertiary)
                                             .padding(.horizontal, 16)
                                     }
                                 }
                                 Spacer(minLength: 16)
                                 self.sort.createView(parentStyle: style)
                                     .padding(.leading, 16)
                                 Spacer(minLength: 12)
                             }
                             .themeColor(background: .layer2)
                             .id(Self.topId)
                             .zIndex(.greatestFiniteMagnitude)

                             Section(header: header) {
                                 self.marketsListViewModel?
                                     .createView()
                                     .padding(.horizontal, 16)
                             }
                             .onChange(of: self.scrollAction) { newValue in
                                 if newValue == .toTop {
                                     withAnimation {
                                         proxy.scrollTo(Self.topId)
                                     }
                                 }
                                 self.scrollAction = .none
                             }
                             .onAppear {
                                 self.scrollAction = .none
                             }

                             // account for scrolling behind tab bar
                             Spacer(minLength: 100)
                         }
                     }
                }
            }
            .themeColor(background: .layer2)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxMarketsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketsViewModel.previewValue.createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}

struct dydxMarketsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketsViewModel.previewValue.createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}
#endif
