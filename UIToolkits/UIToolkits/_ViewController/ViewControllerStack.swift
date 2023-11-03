//
//  UIViewControllerStack.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/28/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

public protocol ViewControllerStackProtocol {
    func didShow(viewController: UIViewController)
    func root() -> UIViewController?
    func topmost() -> UIViewController?
}

public extension ViewControllerStackProtocol {
    func topParent() -> UIViewController? {
        if let topmost = topmost() {
            return topParent(of: topmost)
        }
        return nil
    }

    func topParent(of viewController: UIViewController) -> UIViewController {
        if viewController is UIViewControllerDrawerProtocol || viewController is UIViewControllerEmbeddingProtocol {
            return viewController
        }

        if let parent = viewController.parent {
            let grandParent = parent.parent
            if (grandParent is UITabBarController || grandParent is UISplitViewController || grandParent == nil) && parent is UINavigationController {
                return viewController
            } else {
                return topParent(of: parent)
            }
        } else {
            return viewController
        }
    }
}

public class ViewControllerStack {
    public static var shared: ViewControllerStackProtocol?
}

public protocol ExtensionRootViewControllerProtocol {
    var embedded: UIViewController? { get set }
}

public class UIKitExtensionViewControllerStack: NSObject, ViewControllerStackProtocol {
    public var extensionRoot: (UIViewController & ExtensionRootViewControllerProtocol)?
    private var stack: [Weak<UIViewController>] = []

    public func didShow(viewController: UIViewController) {
        stack.append(Weak<UIViewController>(viewController))
    }

    public func root() -> UIViewController? {
        return extensionRoot
    }

    public func topmost() -> UIViewController? {
        stack.removeAll { (boxed: Weak<UIViewController>) -> Bool in
            boxed.object == nil
        }
        return stack.last?.object ?? root()
    }
}
