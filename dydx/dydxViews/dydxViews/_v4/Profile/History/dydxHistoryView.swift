//
//  dydxHistoryView.swift
//  dydxUI
//
//  Created by Rui Huang on 10/3/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxHistoryViewModel: PlatformViewModel {
    public enum DisplayContent: String {
        case trades, transfers, payments
    }

    @Published public var displayContent: DisplayContent = .trades

    @Published public var headerViewModel: NavHeaderModel? = NavHeaderModel()
    @Published public var selectionBar: SelectionBarModel? = SelectionBarModel()

    @Published public var fills = dydxPortfolioFillsViewModel()
    @Published public var funding = dydxPortfolioFundingViewModel()
    @Published public var transfers = dydxPortfolioTransfersViewModel()

    public init() {
        super.init()

        fills.contentChanged = { [weak self] in
            self?.objectWillChange.send()
        }
        funding.contentChanged = { [weak self] in
            self?.objectWillChange.send()
        }
        transfers.contentChanged = { [weak self] in
            self?.objectWillChange.send()
        }
    }

    public static var previewValue: dydxHistoryViewModel {
        let vm = dydxHistoryViewModel()
        vm.headerViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                self.headerViewModel?.createView(parentStyle: style)

                self.selectionBar?.createView(parentStyle: style)
                    .animation(.default, value: self.selectionBar?.items)

                switch self.displayContent {
                case .trades:
                    ScrollView {
                        LazyVStack {
                            self.fills.createView(parentStyle: style)
                            Spacer(minLength: 128)
                        }
                    }
                case .transfers:
                    ScrollView {
                        LazyVStack {
                            self.transfers.createView(parentStyle: style)
                            Spacer(minLength: 128)
                        }
                    }
                case .payments:
                    ScrollView {
                        LazyVStack {
                            self.funding.createView(parentStyle: style)
                            Spacer(minLength: 128)
                        }
                    }
                }
            }
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer2)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxHistoryView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxHistoryViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxHistoryView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxHistoryViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
