//
//  dydxAlertsProvider.swift
//  dydxPresenters
//
//  Created by Rui Huang on 7/11/23.
//

import Foundation
import dydxViews
import Combine
import Utilities
import PlatformUI

enum AlertType {
    case system
    case transfer
    case frontend
}

protocol dydxCustomAlertsProviderProtocol: dydxAlertsProviderProtocol {
    var alertType: AlertType { get }
}

protocol dydxAlertsProviderProtocol {
    var items: AnyPublisher<[PlatformViewModel], Never> { get }
    var showAlertIndicator: AnyPublisher<Bool, Never> { get }
}

public final class dydxAlertsProvider: dydxBaseAlertsProvider, SingletonProtocol {
    public static var shared = dydxAlertsProvider()

    private let providers: [any dydxCustomAlertsProviderProtocol] = [
        dydxSystemAlertsProvider(),
        dydxTransferAlertsProvider(),
        dydxFrontendAlertsProvider()
    ]
    private var providerItems = [AlertType: [PlatformViewModel]]()
    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()

        providers.forEach { provider in
            subscribeTo(provider: provider)
        }

        DataLocalizer.shared?.languagePublisher
            .sink { [weak self] _ in
                self?.updateItems()
            }
            .store(in: &subscriptions)
    }

    private func subscribeTo(provider: dydxCustomAlertsProviderProtocol) {
        provider.items
            .sink { [weak self] (viewModels: [PlatformViewModel]) in
                self?.providerItems[provider.alertType] = viewModels
                self?.updateItems()
            }
            .store(in: &subscriptions)

        provider.showAlertIndicator
            .sink { [weak self] show in
                self?._showAlertIndicator = self?._showAlertIndicator ?? false || show
            }
            .store(in: &subscriptions)
    }

    private func updateItems() {
        var viewModels = [PlatformViewModel]()
        providers.forEach { provider in
            viewModels.append(contentsOf: providerItems[provider.alertType] ?? [])
        }
        if viewModels.count > 0 {
            _items = viewModels
        } else {
            _items = [PlaceholderViewModel(text: DataLocalizer.localize(path: "APP.V4.ALERTS_PLACHOLDER"))]
        }
    }
}

open class dydxBaseAlertsProvider: dydxAlertsProviderProtocol {
    var items: AnyPublisher<[PlatformViewModel], Never> {
        $_items
            .eraseToAnyPublisher()
    }

    var showAlertIndicator: AnyPublisher<Bool, Never> {
        $_showAlertIndicator
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    @Published var _items: [PlatformViewModel] = []
    @Published var _showAlertIndicator: Bool = false
}
