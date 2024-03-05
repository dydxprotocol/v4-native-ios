//
//  TransitionDelegate.swift
//  PlatformRouting
//
//  Created by Michael Maguire on 3/1/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Foundation

enum CustomTransition {
    case fade
    
    var transitionDelegate: UIViewControllerTransitioningDelegate {
        switch self {
        case .fade:
            CustomTransitionDelegate(transitioner: FadeInFadeOutAnimator())
        }
    }
}

protocol RoutingCustomTransitionable: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    var isPresenting: Bool { get set }
    var duration: TimeInterval { get }
}

private class CustomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let transitioner: RoutingCustomTransitionable
    
    public init(transitioner: RoutingCustomTransitionable) {
        self.transitioner = transitioner
        super.init()
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioner.isPresenting = true
        return transitioner
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitioner.isPresenting = false
        return transitioner
    }
}
