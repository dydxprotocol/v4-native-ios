//
//  RoutingContainingController.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 6/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import RoutingKit
import UIAppToolkits
import UIToolkits
import Utilities

open class RoutingContainingController: UIViewController, UIViewControllerEmbeddingProtocol {
    @IBOutlet public var embedding: UIView?
    @IBOutlet public var floating: UIView?

    public var stacked: Bool = false {
        didSet {
            if stacked != oldValue {
                updateStacked()
            }
        }
    }

    @IBOutlet public var stackedContaints: [NSLayoutConstraint]?

    private var navigationDebouncer: Debouncer = Debouncer()

    public var embedded: UIViewController? {
        get {
            if let embedding = embedding {
                return children.first { (viewController) -> Bool in
                    viewController.view.superview === embedding
                }
            }
            return nil
        }
        set {
            if newValue !== embedded {
                remove(embedded)
                embed(newValue, in: embedding)
            }
        }
    }

    public var floated: UIViewController? {
        get {
            if let floating = floating {
                return children.first { (viewController) -> Bool in
                    viewController.view.superview === floating
                }
            }
            return nil
        }
        set {
            if newValue !== floated {
                remove(floated)
                embed(newValue, in: floating)
            }
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stacked = traitCollection.horizontalSizeClass == .compact
    }

    open func embed(_ viewController: UIViewController?, animated: Bool) -> Bool {
        if embedding != nil {
            embedded = viewController
            return true
        }
        return false
    }

    open func float(_ viewController: UIViewController?, animated: Bool) -> Bool {
        if floating != nil {
            floated = viewController
            return true
        }
        return false
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        stacked = (traitCollection.horizontalSizeClass == .compact)
    }

    open func updateStacked() {
        let priority: Float = stacked ? 751 : 749
        if let constraints = stackedContaints {
            for constraint in constraints {
                constraint.priority = UILayoutPriority(rawValue: priority)
            }
        }
    }
}

extension RoutingContainingController: NavigableProtocol {
    public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.navigate(to: request, viewControllerIndex: 0, animated: animated) { [weak self] object, completed in
                if completed {
                    self?.navigationItem.title = (object as? UIViewController)?.navigationItem.title
                }
                completion?(object, completed)
            }
        }
    }

    public func navigate(to request: RoutingRequest?, viewControllerIndex: Int, animated: Bool, completion: RoutingCompletionBlock?) {
        if viewControllerIndex < children.count {
            let viewController = children[viewControllerIndex]
            if let destination = viewController as? NavigableProtocol {
                destination.navigate(to: request, animated: animated) { [weak self] _, completed in
                    if completed {
                        completion?(destination, true)
                    } else {
                        self?.navigate(to: request, viewControllerIndex: viewControllerIndex + 1, animated: animated, completion: completion)
                    }
                }
            } else {
                navigate(to: request, viewControllerIndex: viewControllerIndex + 1, animated: animated, completion: completion)
            }
        } else {
            completion?(nil, false)
        }
    }
}
