//
//  MappedUIKitExtensionRouter.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 12/28/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit
import UIToolkits

open class MappedUIKitExtensionRouter: MappedUIKitRouter {
    internal override func root(_ viewController: UIViewController, animated: Bool, completion: RoutingCompletionBlock?) {
        DispatchQueue.main.async {
            if var root = (ViewControllerStack.shared as? UIKitExtensionViewControllerStack)?.extensionRoot {
                root.embedded = UIViewController.navigation(with: viewController)
                completion?(nil, true)
            } else {
                completion?(nil, false)
            }
        }
    }
}
