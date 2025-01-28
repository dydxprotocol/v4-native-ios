//
//  dydxAppModeViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 17/12/2024.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxAnalytics

public class dydxAppModeViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxAppModeViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxAppModeViewController(presenter: presenter, view: view, configuration: .fullScreenSheet) as? T
    }
}

private class dydxAppModeViewController: HostingViewController<PlatformView, dydxAppModeViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/settings/app_mode" {
            return true
        }
        return false
    }
}

private protocol dydxAppModeViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxAppModeViewModel? { get }
}

private class dydxAppModeViewPresenter: HostedViewPresenter<dydxAppModeViewModel>, dydxAppModeViewPresenterProtocol {

    private let settingsStore = SettingsStore.shared

    override init() {
        super.init()

        viewModel = dydxAppModeViewModel()
    }

    override func start() {
        super.start()

        viewModel?.appMode = AppMode.current
        viewModel?.onChange = { [weak self]  mode in
            if mode != self?.viewModel?.appMode {
                self?.viewModel?.appMode = mode
                AppMode.current = mode
            }

            self?.loadRoot()
        }
        viewModel?.onCancel = { [weak self] in
            self?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }

    override func onHalfSheetDismissal() {
        super.onHalfSheetDismissal()

        if AppMode.current == nil {
            // Defaulting to Simple
            AppMode.current = .simple
            loadRoot()
        }
    }

    private func loadRoot() {
        navigate(to: RoutingRequest(path: "/loading"), animated: true, completion: { _, _ in
            self.navigate(to: RoutingRequest(path: "/"), animated: true, completion: { _, _ in
            })
        })
    }
}

public extension AppMode {
    static var current: AppMode? {
        get {
            if let appMode = SettingsStore.shared?.value(forDydxKey: .appMode) as? String {
                return AppMode(rawValue: appMode)
            }
            return nil
        }
        set {
            if current != newValue {
                let fromMode = current?.rawValue ?? "none"
                let toMode = newValue?.rawValue ?? "none"
                Tracking.shared?.log(event: AnalyticsEventV2.ModeSelectorEvent(fromMode: fromMode, toMode: toMode))

                SettingsStore.shared?.setValue(newValue?.rawValue, forDydxKey: .appMode)
            }
        }
    }
}
