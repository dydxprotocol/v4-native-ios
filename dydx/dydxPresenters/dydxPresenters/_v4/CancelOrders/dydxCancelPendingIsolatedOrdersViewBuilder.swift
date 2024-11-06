//
//  dydxCancelPendingIsolatedOrdersViewBuilder.swift
//  dydxUI
//
//  Created by Michael Maguire on 6/17/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//
import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Combine

public class dydxCancelPendingIsolatedOrdersViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxCancelPendingIsolatedOrdersViewBuilderPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxCancelPendingIsolatedOrdersViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxCancelPendingIsolatedOrdersViewController: HostingViewController<PlatformView, dydxCancelPendingIsolatedOrdersViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if let marketId = request?.params?["market"] as? String,
            request?.path == "/portfolio/cancel_pending_position",
           let presenter = presenter as? dydxCancelPendingIsolatedOrdersViewBuilderPresenterProtocol {
            presenter.marketId = marketId
            return true
        }
        return false
    }
}

private protocol dydxCancelPendingIsolatedOrdersViewBuilderPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxCancelPendingIsolatedOrdersViewModel? { get }
    var marketId: String? { get set }
}

private class dydxCancelPendingIsolatedOrdersViewBuilderPresenter: HostedViewPresenter<dydxCancelPendingIsolatedOrdersViewModel>, dydxCancelPendingIsolatedOrdersViewBuilderPresenterProtocol {
    fileprivate var marketId: String?

    override init() {
        super.init()

        self.viewModel = .init(marketLogoUrl: nil, assetName: "Ethereum", assetId: "ETH", orderCount: 0, cancelAction: {})
    }

    override func start() {
        super.start()

        let pendingOrdersPublisher = AbacusStateManager.shared.state.selectedSubaccountOrders
            .filterMany { [weak self] order in
                order.marketId == self?.marketId && order.status == .open
            }

        Publishers.CombineLatest(
            AbacusStateManager.shared.state.configsAndAssetMap,
            pendingOrdersPublisher
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] configsAndAssetMap, pendingOrders in
            guard let self = self,
                  let marketId = self.marketId,
                  let asset = configsAndAssetMap[marketId]?.asset
            else { return }
            self.viewModel?.marketLogoUrl = URL(string: asset.resources?.imageUrl ?? "")
            self.viewModel?.assetName = asset.name ?? "--"
            self.viewModel?.assetId = asset.displayableAssetId
            self.viewModel?.orderCount = pendingOrders.count
            self.viewModel?.failureCount = self.viewModel?.failureCount
            self.viewModel?.cancelAction = { [weak self] in
                self?.tryCancelOrders(orderIds: pendingOrders.map(\.id))
            }
        }
        .store(in: &subscriptions)
    }

    private func tryCancelOrders(orderIds: [String]) {
        viewModel?.state = viewModel?.failureCount == nil ? .submitting : .resubmitting
        Task { [weak self] in
            guard let self = self else { return }

            // Create an array to hold the results of the cancellations
            var results: [Result<AbacusStateManager.SubmissionStatus, Error>] = []

            // Use a TaskGroup to kick off multiple calls and wait for all to finish
            await withTaskGroup(of: Result<AbacusStateManager.SubmissionStatus, Error>.self) { group in
                for orderId in orderIds {
                    group.addTask {
                        do {
                            let status = try await AbacusStateManager.shared.cancelOrder(orderId: orderId)
                            return .success(status)
                        } catch {
                            return .failure(error)
                        }
                    }
                }

                // Collect the results of all tasks
                for await result in group {
                    results.append(result)
                }
            }

            // Count the number of failed cancellations
            let failureCount = results.filter { result in
                if case .failure = result {
                    return true
                }
                return false
            }.count

            await updateState(failureCount: failureCount)
        }
    }

    @MainActor
    private func updateState(failureCount: Int) {
        self.viewModel?.failureCount = failureCount

        if failureCount > 0 {
            self.viewModel?.state = .failed
        } else {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }

}
