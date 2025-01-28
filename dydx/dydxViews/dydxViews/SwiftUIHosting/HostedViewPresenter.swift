//
//  HostedViewPresenter.swift
//  dydxViews
//
//  Created by Rui Huang on 9/30/22.
//

import Foundation
import ParticlesKit
import Combine
import PlatformUI
import PlatformParticles
import Utilities
import RoutingKit
import dydxAnalytics

public protocol HostedViewPresenterProtocol: WorkerProtocol {
    var currentRoute: RoutingRequest? { get set }
}

open class HostedViewPresenter<ViewModel: PlatformViewModeling>: ObjectViewPresenter, HostedViewPresenterProtocol {
    @Published public var viewModel: ViewModel?
    public var subscriptions = Set<AnyCancellable>()
    public var isStarted = false

    private var workers = [WorkerProtocol]()

    public var currentRoute: RoutingRequest? {
        didSet {
            for worker in workers {
                if let presenter = worker as? HostedViewPresenterProtocol {
                    presenter.currentRoute = currentRoute
                }
            }
        }
    }

    deinit {
        detachChildren(workers: workers)
    }

    open func start() {
        if !isStarted {
            isStarted = true

            workers.forEach { $0.start() }

            Console.shared.log("\(String(describing: Self.className())) started")
        }
    }

    open func stop() {
        if isStarted {
            subscriptions.forEach { cancellable in
                cancellable.cancel()
            }
            subscriptions.removeAll()
            isStarted = false

            workers.forEach { $0.stop() }

            Console.shared.log("\(String(describing: Self.className())) stopped")
        }
    }

    open func onHalfSheetDismissal() {

    }

    public func attachChild(worker: WorkerProtocol) {
        if workers.contains(where: { $0 === worker }) == false {
            workers.append(worker)
        }

        if isStarted {
            worker.start()
        }
    }

    public func detachChild(worker: WorkerProtocol) {
        if let index = workers.firstIndex(where: { $0 === worker }) {

            let worker = workers[index]
            if isStarted {
                worker.stop()
            }
            workers.remove(at: index)
        }
    }

    public func attachChildren(workers: [WorkerProtocol]) {
        workers.forEach { worker in
            if let presenter = worker as? HostedViewPresenterProtocol {
                presenter.currentRoute = currentRoute
            }
            attachChild(worker: worker)
        }
    }

    public func detachChildren(workers: [WorkerProtocol]) {
        workers.forEach { detachChild(worker: $0) }
    }

    public func navigate(to request: RoutingRequest, animated: Bool, completion: RoutingCompletionBlock?) {
        if let toRoute = request.url?.relativePath {
            let event = AnalyticsEventV2.RoutingEvent(fromPath: currentRoute?.url?.relativePath,
                                                      toPath: toRoute,
                                                      fromQuery: currentRoute?.url?.query,
                                                      toQuery: request.url?.query)
            Tracking.shared?.log(event: event)
        }

        Router.shared?.navigate(to: request, animated: animated, completion: completion)
    }

}

public class SimpleHostedViewPresenter: HostedViewPresenter<PlatformViewModel> {}
