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

public protocol HostedViewPresenterProtocol: WorkerProtocol {}

open class HostedViewPresenter<ViewModel: PlatformViewModeling>: ObjectViewPresenter, HostedViewPresenterProtocol {
    @Published public var viewModel: ViewModel?
    public var subscriptions = Set<AnyCancellable>()
    public var isStarted = false

    private var workers = [WorkerProtocol]()

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
        workers.forEach { attachChild(worker: $0) }
    }

    public func detachChildren(workers: [WorkerProtocol]) {
        workers.forEach { detachChild(worker: $0) }
    }

}

public class SimpleHostedViewPresenter: HostedViewPresenter<PlatformViewModel> {}
