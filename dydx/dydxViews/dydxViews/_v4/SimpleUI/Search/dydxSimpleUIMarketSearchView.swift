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

public class dydxSimpleUIMarketSearchViewModel: PlatformViewModel {
    @Published public var marketList: dydxSimpleUIMarketListViewModel?
    @Published public var onTextChanged: ((String) -> Void)?
    @Published public var keyboardUp: Bool = false

    public init() { }

    public static var previewValue: dydxSimpleUIMarketSearchViewModel {
        let vm = dydxSimpleUIMarketSearchViewModel()
        vm.marketList = .previewValue
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

            let view = ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(pinnedViews: [.sectionHeaders]) {

                            let marketHeader = self.createHeader(text: DataLocalizer.localize(path: "APP.GENERAL.MARKETS"))
                            Section(header: marketHeader) {
                                self.marketList?.createView(parentStyle: style)

                                Spacer(minLength: 96)
                            }
                        }
                    }
                    .clipped()      // prevent blending into status bar
                }

                SearchBoxModel(searchText: "", focusedOnAppear: true, onEditingChanged: { [weak self] focused in
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

    private func createHeader(text: String) -> some View {
        VStack(spacing: 0) {
            Text(text)
                .themeFont(fontType: .plus)
                .themeColor(foreground: .textPrimary)
                .leftAligned()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
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
