//
//  UXNavigationController.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/1/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit

@objc public protocol UXNavigationPopProtocol: NSObjectProtocol {
    @objc func shouldPop() -> Bool
}

open class UXNavigationController: UINavigationController, UINavigationBarDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
//        navigationBar.barStyle = .black
//        navigationBar.barTintColor = UIColor(named: "Base")
        navigationBar.shadowImage = UIImage()
    }

    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        var shouldPop = true
        let viewController = viewControllers.last
        if item == viewController?.navigationItem {
            shouldPop = (viewController as? UXNavigationPopProtocol)?.shouldPop() ?? true
        }
        if #available(iOS 13.0, *) {
            // do nothing
        } else if shouldPop {
            popViewController(animated: true)
        }
        return shouldPop
    }
}
