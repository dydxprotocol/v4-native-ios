//
//  UIViewControllerProtocols.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/1/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit

@objc public protocol FloatingProtocol: NSObjectProtocol {
    @objc var halved: UIViewController? { get }
    @objc func half(_ viewController: UIViewController?, animated: Bool)
    @objc func dismiss(_ viewController: UIViewController?, animated: Bool)
}

@objc public protocol EmbeddingProtocol: NSObjectProtocol {
    @objc var floated: UIViewController? { get set }
    @objc func float(_ viewController: UIViewController?, animated: Bool)

    @objc var embedded: UIViewController? { get set }
    @objc func embed(_ viewController: UIViewController?, animated: Bool)

    func installEmbedded()
}

@objc public protocol UIViewControllerHalfProtocol: NSObjectProtocol {
    @objc var floatingManager: FloatingProtocol? { get set }
    @objc func dismiss(_ viewController: UIViewController?, animated: Bool)
}

@objc public protocol UIViewControllerEmbeddingProtocol: NSObjectProtocol {
    @objc var floated: UIViewController? { get set }
    @objc func embed(_ viewController: UIViewController?, animated: Bool) -> Bool

    @objc var embedded: UIViewController? { get set }
    @objc func float(_ viewControler: UIViewController?, animated: Bool) -> Bool
}

@objc public protocol UIViewControllerDrawerProtocol: NSObjectProtocol {
    @objc var left: UIViewController? { get set }
    @objc var center: UIViewController? { get set }
    @objc var isOpen: Bool { get }
}
