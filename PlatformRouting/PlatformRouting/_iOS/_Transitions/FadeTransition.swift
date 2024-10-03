//
//  FadeTransition.swift
//  PlatformRouting
//
//  Created by Michael Maguire on 3/1/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Foundation

// Animator for custom transition
class FadeInFadeOutAnimator: NSObject, RoutingCustomTransitionable {
    var isPresenting = true
    let duration = 0.5

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        guard let controller = transitionContext.viewController(forKey: key) else { return }

        if isPresenting {
            transitionContext.containerView.addSubview(controller.view)
            controller.view.alpha = 0
        }

        UIView.animate(withDuration: duration, animations: {
            controller.view.alpha = self.isPresenting ? 1 : 0
        }) { _ in
            if !self.isPresenting {
                controller.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
