//
//  dydxMarketInfoView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/6/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketInfoViewModel: PlatformViewModel {
    @Published public var header = dydxMarketInfoHeaderViewModel()
    @Published public var paging: dydxMarketInfoPagingViewModel? = dydxMarketInfoPagingViewModel()
    @Published public var stats: dydxMarketStatsViewModel? = dydxMarketStatsViewModel()
    @Published public var resources = dydxMarketResourcesViewModel()
    @Published public var configs: dydxMarketConfigsViewModel? = dydxMarketConfigsViewModel()

    @Published public var sections = dydxPortfolioSectionsViewModel()
    @Published public var fills = dydxPortfolioFillsViewModel()
    @Published public var position = dydxMarketPositionViewModel()
    @Published public var orders = dydxPortfolioOrdersViewModel()
    @Published public var funding = dydxPortfolioFundingViewModel()
    @Published public var sectionSelection: PortfolioSection = .positions

    public init() {
        super.init()
        position.contentChanged = { [weak self] in
            self?.objectWillChange.send()
        }
        orders.contentChanged = { [weak self] in
            self?.objectWillChange.send()
        }
        funding.contentChanged = { [weak self] in
            self?.objectWillChange.send()
        }
        fills.contentChanged = { [weak self] in
            self?.objectWillChange.send()
        }
    }

    public static var previewValue: dydxMarketInfoViewModel = {
        let vm = dydxMarketInfoViewModel()
        vm.header = .previewValue
        vm.paging = .previewValue
        vm.stats = .previewValue
        vm.resources = .previewValue
        vm.configs = .previewValue
        vm.sections = .previewValue
        vm.position = .previewValue
        vm.orders = .previewValue
        vm.funding = .previewValue
        vm.fills = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 0) {
                self.header
                    .createView(parentStyle: style)
                    .frame(width: UIScreen.main.bounds.width)

                ScrollView(showsIndicators: false) {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        self.createChartPagesSection(parentStyle: style)

                        self.createPositionSection(parentStyle: style)
                        Spacer(minLength: 24)

                        self.createStatsSection(parentStyle: style)

                        self.createDetailsSection(parentStyle: style)

                        self.createConfigsSection(parentStyle: style)

                        // for tab bar scroll adjstment overlap
                        Spacer(minLength: 128)
                    }
                    .themeColor(background: .layer2)
                }

                Spacer()
            }
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer2)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createChartPagesSection(parentStyle: ThemeStyle) -> some View {
        paging?
            .createView(parentStyle: parentStyle)
            .frame(height: 360)
    }

    private func createPositionSection(parentStyle: ThemeStyle) -> some View {
        let header = Group {
             sections.createView(parentStyle: parentStyle)
                 .padding(.horizontal, 16)
         }
             .frame(width: UIScreen.main.bounds.width)
             .themeColor(background: .layer2)

        return VStack {
            header
            switch sectionSelection {
            case .trades:
                fills
                    .createView(parentStyle: parentStyle)
            case .positions:
                position
                    .createView(parentStyle: parentStyle)
            case .orders:
                orders
                    .createView(parentStyle: parentStyle)
            case .funding:
                funding
                    .createView(parentStyle: parentStyle)
            case .transfers, .fees:
                PlatformView.nilView
            }
        }
    }

    private func createStatsSection(parentStyle: ThemeStyle) -> some View {
            stats?
                .createView(parentStyle: parentStyle)
                .frame(width: UIScreen.main.bounds.width)
                .sectionHeader(path: "APP.GENERAL.STATISTICS")
    }

    private func createDetailsSection(parentStyle: ThemeStyle) -> some View {
        resources
            .createView(parentStyle: parentStyle)
            .frame(width: UIScreen.main.bounds.width)
            .sectionHeader(path: "APP.GENERAL.DETAILS")
    }

    private func createConfigsSection(parentStyle: ThemeStyle) -> some View {
        configs?
            .createView(parentStyle: parentStyle)
            .padding(.horizontal, 8)
            .frame(width: UIScreen.main.bounds.width)
    }
}

extension View {
    func sectionHeader(path: String) -> some View {
        self.modifier(SectionModifier(localizedStringPath: path))
    }

    func sectionHeader(header: @escaping (() -> some View)) -> some View {
        self.modifier(SectionHeaderModifier(header: header))
    }
}

private struct SectionModifier: ViewModifier {
    var localizedStringPath: String?

    func body(content: Content) -> some View {
        Section {
            VStack(alignment: .leading) {
                content
                Spacer(minLength: 24)
            }
        } header: {
            if let localizedStringPath {
                VStack(alignment: .leading) {
                    HStack {
                        Text(DataLocalizer.localize(path: localizedStringPath))
                            .themeFont(fontType: .plus, fontSize: .largest)
                            .padding(.leading, 16)
                        Spacer()
                    }
                    Spacer(minLength: 16)
                }
                .themeColor(background: .layer2)
            }
        }
    }
}

private struct SectionHeaderModifier<Parent>: ViewModifier where Parent: View {
    var header: (() -> Parent)

    func body(content: Content) -> some View {
        Section {
            VStack(alignment: .leading) {
                content
                Spacer(minLength: 24)
            }
        } header: {
            header()
                .themeColor(background: .layer2)
        }
    }
}

#if DEBUG
struct dydxMarketInfoView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketInfoViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}

struct dydxMarketInfoView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketInfoViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}
#endif
