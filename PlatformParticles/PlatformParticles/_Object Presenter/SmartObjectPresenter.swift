//
//  SmartObjectPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/29/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

@objc open class SmartObjectPresenter: ObjectViewPresenter {
    @IBOutlet var childPresenters: [ObjectPresenter]?
    var lookup: [String: UIView] = [String: UIView]()

    override open var model: ModelObjectProtocol? {
        didSet {
            if model !== oldValue {
                for (tag, _) in lookup {
                    kvoController.unobserve(oldValue, keyPath: tag)
                }
                lookup.removeAll()
                update(layout: oldValue != nil)
            }
        }
    }

    open func update(layout: Bool) {
        if let view = view {
            update(view: view)
            if layout {
                updateLayout(view: view)
            }
        }
    }

    open func update(view: UIView) {
        if let binding = view.binding {
            update(binding: binding, view: view)
        } else {
            for child in view.subviews {
                update(view: child)
            }
        }
    }

    private func update(binding: String, view: UIView) {
        if lookup[binding] == nil {
            // this is to deal with many views with the same tag. Only one is updated
            lookup[binding] = view
            kvoController.observe(model, keyPath: binding, options: [.initial]) { [weak self] _, _, _ in
                if let self = self, let model = self.model as? (NSObject & ModelObjectProtocol) {
                    if let label = view as? LabelProtocol {
                        label.text = self.parser.asString(model.value(forKey: binding))?.localized
                    } else if let imageView = view as? CachedImageView {
                        imageView.imageUrl = self.parser.asURL(model.value(forKey: binding))
                    } else if let imageView = view as? ImageViewProtocol {
                        if let imageName = self.parser.asString(model.value(forKey: binding)) {
                            imageView.image = UIImage.named(imageName, bundles: Bundle.particles)
                        } else {
                            imageView.image = nil
                        }
                    } else {
                        let value = model.value(forKey: binding)
                        if let boolValue = value as? Bool {
                            view.isHidden = !boolValue
                        }
                    }
                }
            }
        }
    }
}
