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
    @Published public var marketSearch: dydxSimpleUIMarketSearchViewModel?
    @Published public var keyboardUp: Bool = false
    @Published public var portfolio: dydxSimpleUIPortfolioViewModel?
    @Published public var header: dydxSimpleUIMarketsHeaderViewModel?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketsViewModel {
        let vm = dydxSimpleUIMarketsViewModel()
        vm.marketList = .previewValue
        vm.marketSearch = .previewValue
        vm.portfolio = .previewValue
        vm.header = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let bottomPadding = max((self.safeAreaInsets?.bottom ?? 0), 16)

            let view = VStack(spacing: 8) {
                self.header?.createView(parentStyle: style)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                ZStack(alignment: .bottom) {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(pinnedViews: [.sectionHeaders]) {
                            if self.keyboardUp == false {
                                Section {
                                    self.portfolio?.createView(parentStyle: style)
                                        .frame(height: 240)
                                        .padding(.bottom, 24)
                                }
                            }

                            DividerModel().createView(parentStyle: style)

                            Section {
                                self.marketList?.createView(parentStyle: style)
                            }
                        }
                        .keyboardObserving()
                    }

                    let blendedColor = Color(UIColor.blend(color1: ThemeColor.SemanticColor.layer2.uiColor,
                                                           intensity1: 0.05,
                                                           color2: UIColor.clear,
                                                           intensity2: 0.95))
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: [
                            ThemeColor.SemanticColor.layer2.color,
                            blendedColor]),
                        startPoint: .bottom, endPoint: .top)

                    self.marketSearch?.createView(parentStyle: style)
                        .padding(.top, 32)
                        .padding(.bottom, bottomPadding)
                        .frame(maxWidth: .infinity)
                        .background(gradient)
                }
            }
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer2)

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
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
