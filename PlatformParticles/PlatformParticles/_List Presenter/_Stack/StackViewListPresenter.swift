//
//  StackViewListPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 10/30/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

open class StackViewListPresenter: XibListPresenter {
    @IBOutlet public var stack: UIStackView?

    override open var title: String? {
        return "List"
    }

    override open var icon: UIImage? {
        return UIImage.named("view_carousel", bundles: Bundle.particles)
    }

    override open func update() {
        let firstContent = (current == nil)
        current = pending
        refresh(animated: true) { [weak self] in
            self?.updateCompleted(firstContent: firstContent)
        }
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        if let subviews = stack?.arrangedSubviews {
            for subview in subviews {
                stack?.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }
        if let list = interactor?.list {
            for object in list {
                if let xib = xib(object: object), let subview: UIView = XibLoader.load(from: xib) {
                    if let presenterview = subview as? ObjectPresenterView {
                        presenterview.model = object
                        presenterview.layoutIfNeeded()
                    }
                    stack?.addArrangedSubview(subview)
                }
            }
        }
        completion?()
    }
}
