//
//  GridPresenterViewController.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 2/15/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit

open class GridPresenterViewController: TrackingViewController {
    @IBOutlet open var presenterManager: GridPresenterManager?

    open override func awakeFromNib() {
        super.awakeFromNib()
        if presenterManager?.view == nil {
            presenterManager?.view = view
        }
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.presenterManager?.updateLayout()
        }
    }

    open override func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        super.navigate(to: request, animated: animated) { [weak self] object, completed in
            if completed {
                self?.presenterManager?.show(view: request?.params?["view"] as? String)
            }
            completion?(object, completed)
        }
    }
}
