//
//  RoutingEmbeddingViewController.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 1/20/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import FloatingPanel
import RoutingKit
import UIAppToolkits
import UIToolkits
import Utilities

open class RoutingEmbeddingController: UIViewController, ParsingProtocol, UIViewControllerEmbeddingProtocol {
    public var floated: UIViewController? {
        get {
            return embeddingFloatingManager?.floated
        }
        set {
            embeddingFloatingManager?.float(newValue, animated: true)
        }
    }

    public var embedded: UIViewController? {
        get {
            return embeddingFloatingManager?.embedded
        }
        set {
            embeddingFloatingManager?.embed(newValue, animated: true)
        }
    }

    public static var parserOverwrite: Parser?
    override open var parser: Parser {
        return RoutingTabBarController.parserOverwrite ?? super.parser
    }

    public var embeddingFloatingManager: EmbeddingProtocol? {
        return floatingManager as? EmbeddingProtocol
    }

    @IBOutlet public var embeddingContainer: UIView? {
        didSet {
            if embeddingContainer !== oldValue {
                installEmbedded()
            }
        }
    }

    private var lastRequest: RoutingRequest?

    public var embed: String? {
        didSet {
            if embed != oldValue {
                installEmbedded()
            }
        }
    }

    @IBOutlet public var floatingContainer: UIView? {
        didSet {
            if floatingContainer !== oldValue {
                installFloated()
            }
        }
    }

    public var float: String? {
        didSet {
            if float != oldValue {
                installFloated()
            }
        }
    }

    @IBInspectable var path: String?

    private var paths: [String]? {
        return parser.asStrings(path)
    }

    @IBOutlet var floatingHeight: NSLayoutConstraint?

    @IBInspectable open var routingMap: String? {
        didSet {
            if routingMap != oldValue {
                if let destinations = parser.asDictionary(JsonLoader.load(bundles: Bundle.particles, fileName: routingMap)) {
                    embed = parser.asString(destinations["embed"])
                    float = parser.asString(destinations["float"])
                }
            }
        }
    }

    private func installEmbedded() {
        if embeddingContainer != nil, let embed = embed {
            installViewController(path: embed, nav: false) { [weak self] viewController in
                self?.embeddingFloatingManager?.embedded = viewController
            }
        }
    }

    private func installFloated() {
        if floatingContainer != nil, let float = float {
            installViewController(path: float, nav: false) { [weak self] viewController in
                self?.embeddingFloatingManager?.floated = viewController
            }
        }
    }

    open func installViewController(path: String, nav: Bool, completion: @escaping ((UIViewController?) -> Void)) {
        if let router = (Router.shared as? MappedUIKitRouter) {
            router.viewController(for: path) { [weak self] viewController in
                guard let self = self, let viewController = viewController else {
                    completion(nil)
                    return
                }
                if let request = self.lastRequest?.modify(path: path) {
                    (viewController as? NavigableProtocol)?.navigate(to: request, animated: false, completion: nil)
                }
                if nav {
                    completion(UIViewController.navigation(with: viewController))
                } else {
                    completion(viewController)
                }
            }
        } else {
            completion(nil)
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        floatingManager = floatingManager()
    }

    open func floatingManager() -> EmbeddingFloatingManager? {
        return EmbeddingFloatingManager(parent: self)
    }

    override public func topmost() -> UIViewController? {
        return embeddingFloatingManager?.floated?.topmost() ?? embeddingFloatingManager?.embedded?.topmost() ?? super.topmost()
    }

    open func embed(_ viewController: UIViewController?, animated: Bool) -> Bool {
        if let embeddingFloatingManager = embeddingFloatingManager {
            embeddingFloatingManager.embed(viewController, animated: animated)
            return true
        }
        return false
    }

    open func float(_ viewController: UIViewController?, animated: Bool) -> Bool {
        if let embeddingFloatingManager = embeddingFloatingManager {
            embeddingFloatingManager.float(viewController, animated: animated)
            return true
        }
        return false
    }
}

extension RoutingEmbeddingController: NavigableProtocol {
    public var history: RoutingRequest? {
        return RoutingRequest(path: paths?.first ?? "/")
    }

    public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if let paths = paths, let path = request?.path, paths.contains(path) {
            lastRequest = request
            completion?(self, true)
        } else if path == nil, request?.path == "/" {
            lastRequest = request
            completion?(self, true)
        } else {
            navigate(to: request, viewController: embeddingFloatingManager?.embedded, animated: animated) { [weak self] destination, succeeded in
                if succeeded {
                    completion?(destination, succeeded)
                } else {
                    self?.navigate(to: request, viewController: self?.embeddingFloatingManager?.floated, animated: animated, completion: completion)
                }
            }
        }
    }

    public func navigate(to request: RoutingRequest?, viewController: UIViewController?, animated: Bool, completion: RoutingCompletionBlock?) {
        if let viewController = viewController as? NavigableProtocol {
            viewController.navigate(to: request, animated: animated) { _, completed in
                if completed {
                    completion?(viewController, true)
                } else {
                    completion?(nil, false)
                }
            }
        } else {
            completion?(nil, false)
        }
    }
}
