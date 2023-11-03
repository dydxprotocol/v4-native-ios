//
//  dydxPortfolioView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/4/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioViewModel: PlatformViewModel {
    public enum State {
        case onboard
        case onboardCompleted
    }

    public enum DisplayContent: String {
        case overview, positions, orders, trades, fees, transfers, payments
    }

    @Published public var displayContent: DisplayContent = .overview

    @Published public var selector = dydxPortfolioSelectorViewModel()
    @Published public var header = dydxPortfolioHeaderViewModel()
    @Published public var chart = dydxPortfolioChartViewModel()
    @Published public var details = dydxPortfolioDetailsViewModel()
    @Published public var sections = dydxPortfolioSectionsViewModel()
    @Published public var fills = dydxPortfolioFillsViewModel()
    @Published public var positions = dydxPortfolioPositionsViewModel()
    @Published public var orders = dydxPortfolioOrdersViewModel()
    @Published public var funding = dydxPortfolioFundingViewModel()
    @Published public var fees = dydxPortfolioFeesViewModel()
    @Published public var transfers = dydxPortfolioTransfersViewModel()
    @Published public var expanded: Bool = false
    @Published public var expandAction: (() -> Void)?
    @Published public var sectionSelection: PortfolioSection = .positions

    public init() {
        super.init()
        positions.contentChanged = {
            self.objectWillChange.send()
        }
        transfers.contentChanged = {
            self.objectWillChange.send()
        }
        orders.contentChanged = {
            self.objectWillChange.send()
        }
        funding.contentChanged = {
            self.objectWillChange.send()
        }
        fills.contentChanged = {
            self.objectWillChange.send()
        }
    }

    public static var previewValue: dydxPortfolioViewModel {
        let vm = dydxPortfolioViewModel()
        vm.selector = .previewValue
        vm.header = .previewValue
        vm.chart = .previewValue
        vm.details = .previewValue
        vm.sections = .previewValue
        vm.positions = .previewValue
        vm.orders = .previewValue
        vm.funding = .previewValue
        vm.fills = .previewValue
        vm.fees = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                HStack {
                    self.selector.createView(parentStyle: style)
                    Spacer()
                    if [.overview, .transfers].contains(self.displayContent) {
                        self.header.createView(parentStyle: style)
                    }
                }
                .frame(height: 48)
                .padding(.bottom, 8)

                switch self.displayContent {
                case .overview:
                    self.createOverView(style: style)
                case .positions:
                    self.createItemListView(style: style) { [weak self] in
                        self?.positions
                            .createView(parentStyle: style)
                    }
                case .trades:
                    self.createItemListView(style: style) { [weak self] in
                        self?.fills
                            .createView(parentStyle: style)
                    }
                case .orders:
                    self.createItemListView(style: style) { [weak self] in
                        self?.orders
                            .createView(parentStyle: style)
                    }
                case .payments:
                    self.createItemListView(style: style) { [weak self] in
                        self?.funding
                            .createView(parentStyle: style)
                    }
                case .fees:
                    self.fees
                        .createView(parentStyle: style)
                case .transfers:
                    self.createItemListView(style: style) { [weak self] in
                        self?.transfers
                            .createView(parentStyle: style)
                    }
                }

                Spacer()
            }
                .padding(.horizontal, 16)
                .themeColor(background: .layer2)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createOverView(style: ThemeStyle) -> AnyView {
        AnyView(
            ScrollView(showsIndicators: false) {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    ZStack {
                        VStack {
                            Spacer()
                            self.details.createView(parentStyle: style)
                        }

                        VStack {
                            self.chart.createView(parentStyle: style)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .animateHeight(height: self.expanded ? 460 : 332)
                    .animation(.easeIn(duration: 0.2), value: self.expanded)

                    self.sections.createView(parentStyle: style)

                    switch self.sectionSelection {
                    case .trades:
                        self.fills
                            .createView(parentStyle: style)
                    case .positions:
                        self.positions
                            .createView(parentStyle: style)
                    case .orders:
                        self.orders
                            .createView(parentStyle: style)
                    case .funding:
                        self.funding
                            .createView(parentStyle: style)
                    case .transfers, .fees:
                        PlatformView.nilView
                    }
                    // add space to adjust for tab bar
                    Spacer(minLength: 80)
                }
            }
        )
    }

    private func createItemListView(style: ThemeStyle, listContent: (() -> some View)) -> AnyView {
        AnyView(
            ScrollView(showsIndicators: false) {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section {
                        listContent()

                        Spacer(minLength: 80)
                    }
                }
            }
        )
    }
}

#if DEBUG
struct dydxPortfolioView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}

struct dydxPortfolioView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}
#endif
