//
//  UIViewController+Helper.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/23/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

extension UIViewController {
    public var topParent: UIViewController {
        if let parent = parent {
            return parent.topParent
        } else {
            return self
        }
    }

    public func halfParent(of viewController: UIViewController) -> UIViewController? {
        if ((self as AnyObject) as? UIViewControllerHalfProtocol)?.floatingManager?.halved == viewController {
            return self
        } else {
            return parent?.halfParent(of: viewController)
        }
    }

    @IBAction open func dismiss(_ sender: Any?) {
        if let presenting = presentingViewController ?? navigationController?.presentingViewController {
            presenting.dismiss(animated: true, completion: nil)
        } else {
            let halfParent = parent?.halfParent(of: self)
            if halfParent !== self {
                ((halfParent as AnyObject) as? UIViewControllerHalfProtocol)?.dismiss(self, animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }

    public var usableNavigationItem: UINavigationItem {
        if let embedding = parentViewControllerConforming(protocol: UIViewControllerEmbeddingProtocol.self) {
            if (embedding as? UIViewControllerEmbeddingProtocol)?.embedded === self {
                return embedding.navigationItem
            }
        }
        return (parent ?? self).navigationItem
    }
}
