//
//  UIView+Xib.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import UIKit
import UIToolkits
import Utilities

extension UIView {
    public func installView(xib: String?, completion: @escaping ((UIView?) -> Void)) {
        installView(xib: xib, into: self, parentViewController: self.viewController(), completion: completion)
    }

    @objc open func installView(xib: String?, into contentView: UIView?, parentViewController: UIViewController?, completion: @escaping ((UIView?) -> Void)) {
        #if DEBUG
        accessibilityIdentifier = "xib: \(xib ?? "")"
        #endif

        if let contentView = contentView, let xib = xib {
            if let loadedView: UIView = XibLoader.load(from: xib) {
                install(view: loadedView, into: contentView)
                completion(loadedView)
             } else {
                ClassLoader.load(from: xib) { [weak self] viewController in
                    if let self = self, let loadedViewController: UIViewController = viewController {

                        guard let parentViewController = parentViewController else {
                            assertionFailure("parentViewController is required when loading from ClassLoader")
                            completion(nil)
                            return
                        }

                        self.uninstallView(xib: xib, view: nil)

                        parentViewController.addChild(loadedViewController)
                        self.viewControllerXibMap?[xib] = loadedViewController
                        self.install(view: loadedViewController.view, into: contentView)
                        loadedViewController.didMove(toParent: parentViewController)

                        completion(loadedViewController.view)
                    } else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
        }
    }

    public func uninstallView(xib: String?, view: UIView?) {
        if let xib = xib {
            if let existingViewController = viewControllerXibMap?[xib] {
                existingViewController.willMove(toParent: nil)
                existingViewController.removeFromParent()
                viewControllerXibMap?.removeValue(forKey: xib)
            }
        }
        view?.removeFromSuperview()
    }

    private struct AssociatedKey {
        static var bindingKey = "view.xib.viewControllerXibMap"
    }

    private var viewControllerXibMap: [String: UIViewController]? {
        get {
            return associatedObject(base: self, key: &AssociatedKey.bindingKey)
        }
        set {
            retainObject(base: self, key: &AssociatedKey.bindingKey, value: newValue)
        }
    }
}
