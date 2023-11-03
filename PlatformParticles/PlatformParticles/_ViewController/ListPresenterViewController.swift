//
//  ListPresenterViewController.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/12/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit

open class ListPresenterViewController: TrackingViewController {
    @IBOutlet open var presenterManager: ListPresenterManager? {
        didSet {
            changeObservation(from: oldValue, to: presenterManager, keyPath: #keyPath(ListPresenterManager.current)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.current = self.presenterManager?.current
                }
            }
        }
    }

    open var current: ListPresenter?

    open override func awakeFromNib() {
        super.awakeFromNib()
        if presenterManager?.view == nil {
            presenterManager?.view = view
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if presenterManager?.flat ?? false {
            if let presenters = presenterManager?.presenters {
                for presenter in presenters {
                    if presenter.current == nil {
                        setup(presenter: presenter)
                    }
                }
            }
        } else {
            if let current = current, current.current == nil {
                setup(presenter: current)
            }
        }
    }

    open func setup(presenter: ListPresenter) {
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
