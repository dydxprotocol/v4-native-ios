//
//  XibActionPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 2/10/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import UIToolkits

@objc open class XibActionPresenter: ObjectPresenter {
    @IBOutlet var titleLabel: LabelProtocol?
    @IBOutlet var textLabel: LabelProtocol?
    @IBOutlet var imageView: ImageViewProtocol?
    @IBOutlet var colorView: UIView?

    public var action: XibAction? {
        return model as? (XibAction)
    }

    override public var model: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: action, keyPath: #keyPath(XibAction.title)) { [weak self] _, _, _, _ in
                self?.updateTitle()
            }
            changeObservation(from: oldValue, to: action, keyPath: #keyPath(XibAction.text)) { [weak self] _, _, _, _ in
                self?.updateText()
            }
            changeObservation(from: oldValue, to: action, keyPath: #keyPath(XibAction.image)) { [weak self] _, _, _, _ in
                self?.updateImage()
            }
            changeObservation(from: oldValue, to: action, keyPath: #keyPath(XibAction.color)) { [weak self] _, _, _, _ in
                self?.updateColor()
            }
        }
    }

    @IBOutlet var linkButton: ButtonProtocol? {
        didSet {
            (linkButton as? UIButton)?.centerImageAndButton(0, imageOnTop: true)
            oldValue?.removeTarget()
            linkButton?.addTarget(self, action: #selector(link(_:)))
        }
    }

    override public var selectable: Bool {
        if linkButton != nil {
            return false
        } else {
            return action?.request != nil
        }
    }

    @IBAction func link(_ sender: Any?) {
        if let request = action?.request {
            Router.shared?.navigate(to: request, animated: true, completion: nil)
        }
    }

    private func updateTitle() {
        titleLabel?.text = action?.title
    }

    private func updateText() {
        textLabel?.text = action?.text
    }

    private func updateImage() {
        if let imageName = action?.image {
            imageView?.image = UIImage.named(imageName, bundles: Bundle.particles)
        } else {
            imageView?.image = nil
        }
    }

    open func updateColor() {
        colorView?.backgroundColor = ColorPalette.shared.color(system: action?.color)
    }
}
