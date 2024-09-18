////
////  dydxAlertsViewPresenter.swift
////  dydxPresenters
////
////  Created by Rui Huang on 5/3/23.
////
//
//import Utilities
//import dydxViews
//import PlatformParticles
//import RoutingKit
//import ParticlesKit
//import PlatformUI
//import dydxStateManager
//import Abacus
//
//protocol dydxAlertsViewPresenterProtocol: HostedViewPresenterProtocol {
//    var viewModel: dydxAlertsViewModel? { get }
//}
//
//class dydxAlertsViewPresenter: HostedViewPresenter<dydxAlertsViewModel>, dydxAlertsViewPresenterProtocol {
//    private let alertsProvider = dydxAlertsProvider.shared
//
//    override init() {
//        super.init()
//
//        viewModel = dydxAlertsViewModel()
//    }
//
//    override func start() {
//        super.start()
//
//        alertsProvider.items
//            .sink { [weak self] viewModels in
//                self?.viewModel?.items = viewModels
//            }
//            .store(in: &subscriptions)
//    }
//}
