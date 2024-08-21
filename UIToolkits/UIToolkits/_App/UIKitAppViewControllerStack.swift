//
//  UIKitAppViewControllerStack.swift
//  UIAppToolkits
//
//  Created by Qiang Huang on 12/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

#if _tvOS
    import UIKit
#else
    import UIToolkits
#endif

public extension UIViewController {
    static func root() -> UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }

    static func topmost() -> UIViewController? {
        return root()?.topmost()
    }
}

public class UIKitAppViewControllerStack: NSObject, ViewControllerStackProtocol {
    public func didShow(viewController: UIViewController) {
        // Do nothing
    }

    public func root() -> UIViewController? {
        return UIViewController.root()
    }

    public func topmost() -> UIViewController? {
        return UIViewController.topmost()
    }
}
