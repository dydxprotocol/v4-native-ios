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

    override public var selectedIndex: Int {
        didSet {
            if selectedIndex != oldValue {
                update(index: oldValue, selected: false)
                update(index: selectedIndex, selected: true)
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        createCenterButton()
        routingMap = "tabs_v4.json"
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

    private func update(index: Int, selected: Bool) {
        if index != NSNotFound {
            if let item = tabBar.items?[index] {
                update(item: item, index: index, selected: selected)
            }
        }
    }

    private func update(item: UITabBarItem, index: Int, selected: Bool) {
        item.title = selected ? "●" : " "
//        if selected, [0, 3, 4].contains(index), wallet === nil {
//            promptLogin()
//        }
    }

    override public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = tabBar.items {
            for index in 0 ..< items.count {
                let tab = items[index]
                update(item: tab, index: index, selected: tab === item)
            }
        }
    }
}
