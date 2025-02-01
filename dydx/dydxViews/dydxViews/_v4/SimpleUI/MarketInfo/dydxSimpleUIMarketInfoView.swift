//
//  dydxSimpleUIMarketInfoView.swift
//  dydxUI
//
//  Created by Rui Huang on 26/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketInfoViewModel: PlatformViewModel {
    @Published public var header: dydxSimpleUIMarketInfoHeaderViewModel?
    @Published public var chart: dydxSimpleUIMarketCandlesViewModel?
    @Published public var position: dydxSimpleUIMarketPositionViewModel?
    @Published public var details: dydxSimpleUIMarketDetailsViewModel?
    @Published public var buySell: dydxSimpleUIMarketBuySellViewModel?
    @Published public var launchable: dydxSimpleUiMarketLaunchableViewModel?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketInfoViewModel {
        let vm = dydxSimpleUIMarketInfoViewModel()
        vm.header = .previewValue
        vm.chart = .previewValue
        vm.position = .previewValue
        vm.details = .previewValue
        vm.buySell = .previewValue
        vm.launchable = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let bottomPadding = max((self.safeAreaInsets?.bottom ?? 0), 16)

            let view = Group {
                if self.launchable == nil {
                    ZStack(alignment: .bottom) {
                        VStack {
                            self.header?.createView(parentStyle: style)

                            ScrollView(showsIndicators: false) {
                                LazyVStack(pinnedViews: [.sectionHeaders]) {
                                    self.chart?.createView(parentStyle: style)
                                        .padding(.bottom, 18)

                                    self.position?.createView(parentStyle: style)

                                    self.details?.createView(parentStyle: style)

                                    // for tab bar scroll adjstment overlap
                                    Spacer(minLength: 128)
                                }
                            }
                        }

                        VStack(spacing: 0) {
                            HStack {
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(SearchBoxModel.bottomBlendGradiant)

                            self.buySell?.createView(parentStyle: style)
                                .padding(.top, 16)
                                .padding(.bottom, bottomPadding)
                                .themeColor(background: .layer1)
                        }
                    }
                } else {
                    VStack {
                        self.header?.createView(parentStyle: style)
                        self.launchable?.createView(parentStyle: style)
                            .padding(.bottom, bottomPadding)
                    }
                }
            }
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer1)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketInfoView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketInfoViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketInfoView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketInfoViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
