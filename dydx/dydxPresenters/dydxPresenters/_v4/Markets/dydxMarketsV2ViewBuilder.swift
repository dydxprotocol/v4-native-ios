//
//  dydxMarketsV2ViewBuilder.swift
//  dydxUI
//
//  Created by Michael Maguire on 9/23/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//


 
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager

public class dydxMarketsV2ViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxMarketsV2ViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxMarketsV2ViewBuilderController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxMarketsV2ViewBuilderController: HostingViewController<PlatformView, dydxMarketsViewV2ViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        request?.path == "/portfolio/overview" || request?.path == "/markets"
        return false
    }
}
 
private protocol dydxMarketsV2ViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketsViewV2ViewModel? { get }
}

private class dydxMarketsV2ViewPresenter: HostedViewPresenter<dydxMarketsViewV2ViewModel>, dydxMarketsV2ViewPresenterProtocol {
    override init() {
        super.init()

        viewModel = dydxMarketsViewV2ViewModel()
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.marketList
            .map { $0.sorted { $0.id < $1.id } }
            .removeDuplicates()
            .sink { [weak self] markets in
                self?.viewModel?.markets = markets.map { $0.id }
            }
            .store(in: &subscriptions)
    }
}

/********************************/
/********************************/
/********************************/
/********************************/
/********************************/
/********************************/
/********************************/
/********************************/
/********************************/
/********************************/

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketsViewV2ViewModel: PlatformViewModel {
    @Published public var header = dydxMarketsHeaderViewModel()
    @Published public var banner: dydxMarketsBannerViewModel?
    @Published public var summary = dydxMarketSummaryViewModel()
    @Published public var filter = dydxMarketAssetFilterViewModel()

    @Published public var markets: [String]?

    @Published public var searchAction: () -> Void = { assertionFailure() }
    
    public init() { }

    public static var previewValue: dydxMarketsViewV2ViewModel {
        let vm = dydxMarketsViewV2ViewModel()
        return vm
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return dydxMarketsViewV2(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

private struct dydxMarketsViewV2: View {
    @ObservedObject var viewModel: dydxMarketsViewV2ViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                header
                DividerModel().createView()
                markets
            }
        }
    }
    
    var header: some View {
        HStack {
            Text(DataLocalizer.localize(path: "APP.GENERAL.MARKETS", params: nil))
                .themeFont(fontType: .plus, fontSize: .largest)

            Spacer()

            Text(DataLocalizer.localize(path: "APP.GENERAL.SEARCH", params: nil))
                .themeFont(fontType: .plus, fontSize: .small)
                .themeColor(foreground: .textTertiary)

            PlatformButtonViewModel(content: PlatformIconViewModel(type: .asset(name: "icon_search", bundle: Bundle.dydxView),
                                                                   clip: .circle(background: .layer5, spacing: 24, borderColor: .layer6),
                                                                   size: CGSize(width: 42, height: 42)),
                                    type: .iconType,
                                    action: viewModel.searchAction)
                .createView()
        }
        .frame(height: 48)
    }
    
    var markets: some View {
        ForEach(viewModel.markets ?? [], id: \.self) { market in
            Text(market)
                .themeFont(fontType: .base, fontSize: .larger)
                .padding([.top, .bottom], 16)
        }
    }
}
