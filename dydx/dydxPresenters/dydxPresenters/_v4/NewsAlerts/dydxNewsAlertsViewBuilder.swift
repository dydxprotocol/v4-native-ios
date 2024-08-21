//
//  dydxNewsAlertsViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 2/7/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import Abacus

public class dydxNewsAlertsViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxNewsAlertsViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxNewsAlertsViewController(presenter: presenter, view: view, configuration: .tabbarItemView) as? T
    }
}

private class dydxNewsAlertsViewController: HostingViewController<PlatformView, dydxNewsAlertsViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/alerts" {
            return true
        }
        return false
    }
}

private protocol dydxNewsAlertsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxNewsAlertsViewModel? { get }
}

private class dydxNewsAlertsViewPresenter: HostedViewPresenter<dydxNewsAlertsViewModel>, dydxNewsAlertsViewPresenterProtocol {
    private let alertsPresenter = dydxAlertsViewPresenter()

    override init() {
        let viewModel = dydxNewsAlertsViewModel()
        alertsPresenter.$viewModel.assign(to: &viewModel.$alerts)
        super.init()
        self.viewModel = viewModel
        viewModel.alerts?.contentChanged = { [weak self] in
            self?.viewModel?.objectWillChange.send()
        }
    }

    override func start() {
        super.start()

        if let blogs = AbacusStateManager.shared.environment?.links?.blogs {
            viewModel?.blog.url = URL(string: blogs)
            updateSelectionBar()
        }

        attachChild(worker: alertsPresenter)
    }

    private func updateSelectionBar() {
        let selectionBar = SelectionBarModel()
        selectionBar.location = .header
        selectionBar.items = [
            SelectionBarModel.Item(text: DataLocalizer.localize(path: "APP.GENERAL.ALERTS"), isSelected: true),
            SelectionBarModel.Item(text: DataLocalizer.localize(path: "APP.GENERAL.NEWS"), isSelected: false)
        ]
        selectionBar.onSelectionChanged = { [weak self] selectedIndex in
            for index in 0..<(selectionBar.items?.count ?? 0) {
                 selectionBar.items?[index].isSelected = selectedIndex == index
            }
            self?.viewModel?.objectWillChange.send()
        }

        viewModel?.selectionBar = selectionBar
    }
}
