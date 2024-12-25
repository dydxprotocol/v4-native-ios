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
    @Published public var onSettingTapped: (() -> Void)?
    @Published public var marketList: dydxSimpleUIMarketListViewModel?
    @Published public var marketSearch: dydxSimpleUIMarketSearchViewModel?
    @Published public var keyboardUp: Bool = false
    @Published public var portfolio: dydxSimpleUIPortfolioViewModel?

    public init() { }

    public static var previewValue: dydxSimpleUIMarketsViewModel {
        let vm = dydxSimpleUIMarketsViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 16) {
                HStack {
                    Spacer()

                    let text = Text("Settings")
                        .themeColor(foreground: .textPrimary)
                    PlatformButtonViewModel(content: text.wrappedViewModel,
                                            type: .pill) { [weak self] in
                        self?.onSettingTapped?()
                    }
                                            .createView(parentStyle: style)
                }
                .padding(.horizontal)

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

                    self.marketSearch?.createView(parentStyle: style)
                }
            }
                .frame(maxWidth: .infinity)
                .themeColor(background: .transparent)

            return AnyView(view)
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
