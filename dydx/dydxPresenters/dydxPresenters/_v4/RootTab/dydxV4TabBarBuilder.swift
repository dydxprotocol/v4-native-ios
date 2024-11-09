//
//  dydxV4TabBarController.swift
//  dydxPresenters
//
//  Created by John Huang on 12/28/22.
//

import dydxStateManager
import Abacus
import PlatformRouting
import UIKit
import Utilities
import SnapKit
import Combine
import dydxViews
import PlatformUI
import ParticlesKit
import dydxFormatter

public class dydxV4TabBarBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        return dydxV4TabBarController() as? T
    }
}

@objc public class dydxV4TabBarController: RoutingTabBarController {
    public var subscriptions = Set<AnyCancellable>()

     private var firstSubaccount: Subaccount? {
        didSet {
            updateCenterButton()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        createCenterButton()
        maps = dydxBoolFeatureFlag.isVaultEnabled.isEnabled ? Self.tabBarItemInfosV2 : Self.tabBarItemInfos
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AbacusStateManager.shared.state.selectedSubaccount
            .sink { [weak self] account in
                self?.firstSubaccount = account
            }
            .store(in: &subscriptions)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        subscriptions.forEach { cancellable in
            cancellable.cancel()
        }
        subscriptions.removeAll()
    }

    override open func didSetCenterButton(oldValue: UIButton?) {
        super.didSetCenterButton(oldValue: oldValue)
        updateCenterButton()
    }

    private func createCenterButton() {
        centerButton = UIButton()
        centerButton?.setImage(UIImage(named: "icon_trade", in: Bundle.dydxView, with: .none), for: .normal)
        centerButton?.backgroundColor = ThemeColor.SemanticColor.colorPurple.uiColor
        centerButton?.tintColor = ThemeColor.SemanticColor.colorWhite.uiColor
        centerButton?.snp.makeConstraints { make in
            make.size.equalTo(60)
        }
        centerButton?.layer.cornerRadius = 30
        centerButton?.layer.masksToBounds = true
    }

    private func updateCenterButton() {
        centerButton?.buttonImage = UIImage.named("icon_trade", bundles: Bundle.particles)
    }
}

private extension dydxV4TabBarController {
    static let tabBarItemInfos: [TabbarItemInfo] = [
        .init(path: "/portfolio",
              title: DataLocalizer.localize(path: "APP.PORTFOLIO.PORTFOLIO"),
              image: "icon_portfolio",
              split: true),
        .init(path: "/markets",
                title: DataLocalizer.localize(path: "APP.GENERAL.MARKETS"),
                image: "icon_market",
                split: true),
        .init(path: "/trade",
              title: DataLocalizer.localize(path: "APP.GENERAL.TRADE"),
              image: "icon_trade",
              split: true),
        .init(path: "/alerts",
              title: DataLocalizer.localize(path: "APP.GENERAL.ALERTS"),
              image: "icon_alerts",
              split: true),
        .init(path: "/my-profile",
              title: DataLocalizer.localize(path: "APP.GENERAL.PROFILE"),
              image: "icon_profile",
              split: true)
    ]

    static let tabBarItemInfosV2: [TabbarItemInfo] = [
        .init(path: "/portfolio",
              title: DataLocalizer.localize(path: "APP.PORTFOLIO.PORTFOLIO"),
              image: "icon_portfolio",
              split: true),
        .init(path: "/markets",
                title: DataLocalizer.localize(path: "APP.GENERAL.MARKETS"),
                image: "icon_market",
                split: true),
        .init(path: "/trade",
              title: DataLocalizer.localize(path: "APP.GENERAL.TRADE"),
              image: "icon_trade",
              split: true),
        .init(path: "/vault",
              title: DataLocalizer.localize(path: "APP.VAULTS.VAULT"),
              image: "icon_earn",
              split: true),
        .init(path: "/my-profile",
              title: DataLocalizer.localize(path: "APP.GENERAL.PROFILE"),
              image: "icon_profile",
              split: true)
    ]
}
