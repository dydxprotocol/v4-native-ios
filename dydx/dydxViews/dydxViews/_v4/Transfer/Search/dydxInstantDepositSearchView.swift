//
//  dydxInstantDepositSearchView.swift
//  dydxUI
//
//  Created by Rui Huang on 21/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxInstantDepositSearchViewModel: PlatformViewModel {
    @Published public var cancelAction: (() -> Void)?
    @Published public var tokens: [dydxInstantDepositSearchItemViewModel]?
    @Published public var otherTokens: [dydxInstantDepositSearchItemViewModel]?
    @Published public var nobleItem: dydxTransferNobleItemViewModel?
    @Published public var fiatItem: dydxTransferFiatItemViewModel?

    public init() { }

    public static var previewValue: dydxInstantDepositSearchViewModel {
        let vm = dydxInstantDepositSearchViewModel()
        vm.tokens = [.previewValue]
        vm.otherTokens = [.previewValue]
        vm.nobleItem = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {

                HStack {
                    ChevronBackButtonModel(onBackButtonTap: self.cancelAction ?? {})
                        .createView(parentStyle: style)

                    Text(DataLocalizer.localize(path: "APP.GENERAL.SELECT_TOKEN"))
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontSize: .larger)
                        .centerAligned()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(height: 54)

                DividerModel().createView(parentStyle: style)

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {

                        let header = self.createHeader(text: DataLocalizer.localize(path: "APP.GENERAL.YOUR_TOKENS"))
                        Section(header: header) {
                            self.nobleItem?.createView(parentStyle: style)
                                .padding(.horizontal, 16)

                            self.fiatItem?.createView(parentStyle: style)
                                .padding(.horizontal, 16)

                            ForEach(self.tokens ?? [], id: \.id) { item in
                                item.createView(parentStyle: style)
                                    .padding(.horizontal, 16)
                            }
                        }

                        let otherHeader = self.createHeader(text: DataLocalizer.localize(path: "APP.GENERAL.OTHER_TOKENS"))
                        Section(header: otherHeader) {
                            ForEach(self.otherTokens ?? [], id: \.id) { item in
                                item.createView(parentStyle: style)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
                .themeColor(background: .layer1)

            return AnyView(view)
        }
    }

    private func createHeader(text: String) -> some View {
        VStack(spacing: 0) {
            Text(text)
                .themeFont(fontType: .plus)
                .themeColor(foreground: .textTertiary)
                .leftAligned()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .themeColor(background: .layer1)
    }
}

#if DEBUG
struct dydxInstantDepositSearchView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositSearchViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxInstantDepositSearchView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxInstantDepositSearchViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
