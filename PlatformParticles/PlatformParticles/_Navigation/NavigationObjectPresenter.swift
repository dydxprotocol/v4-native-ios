//
//  NavigationObjectPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/30/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesCommonModels
import ParticlesKit
import RoutingKit
import UIToolkits

@objc public class NavigationObjectPresenter: ObjectPresenter {
    @IBOutlet public var titleLabel: LabelProtocol?
    @IBOutlet public var subtitleLabel: LabelProtocol?
    @IBOutlet public var textLabel: LabelProtocol?
    @IBOutlet public var subtextLabel: LabelProtocol?
    @IBOutlet public var colorView: ViewProtocol?
    @IBOutlet public var iconView: CachedImageView?
    @IBOutlet public var imageView: CachedImageView?
    @IBOutlet public var actionButton: ButtonProtocol?
    @IBOutlet public var childrenPresenter: ListPresenter?
    @IBOutlet public var actionsPresenter: ListPresenter?

    @objc override public var model: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.title)) { [weak self] _, _, _, _ in
                self?.titleLabel?.text = self?.navigationObject?.title
                self?.actionButton?.buttonTitle = self?.navigationObject?.title
            }
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.subtitle)) { [weak self] _, _, _, _ in
                self?.subtitleLabel?.text = self?.navigationObject?.subtitle
            }
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.text)) { [weak self] _, _, _, _ in
                self?.textLabel?.text = self?.navigationObject?.text
            }
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.subtext)) { [weak self] _, _, _, _ in
                self?.subtextLabel?.text = self?.navigationObject?.subtext
            }
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.color)) { [weak self] _, _, _, _ in
                self?.colorView?.backgroundColor = ColorPalette.shared.color(system: self?.navigationObject?.color)
            }
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.icon)) { [weak self] _, _, _, _ in
                self?.iconView?.imageUrl = self?.navigationObject?.icon
            }
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.image)) { [weak self] _, _, _, _ in
                self?.imageView?.imageUrl = self?.navigationObject?.image
            }
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.children)) { [weak self] _, _, _, _ in
                self?.syncChildren()
            }
            changeObservation(from: oldValue, to: model, keyPath: #keyPath(NavigationModelProtocol.actions)) { [weak self] _, _, _, _ in
                self?.syncActions()
            }
        }
    }

    public var navigationObject: NavigationModelProtocol? {
        return model as? NavigationModelProtocol
    }

    @IBOutlet public var children: ListInteractor? {
        didSet {
            childrenPresenter?.interactor = children
        }
    }

    @IBOutlet public var actions: ListInteractor? {
        didSet {
            actionsPresenter?.interactor = actions
        }
    }

    private func syncChildren() {
        if let children = navigationObject?.children {
            let list = self.children ?? ListInteractor()
            list.sync(children)
            self.children = list
        } else {
            children = nil
        }
    }

    private func syncActions() {
        if let actions = navigationObject?.actions {
            let list = self.actions ?? ListInteractor()
            list.sync(actions)
            self.actions = list
        } else {
            actions = nil
        }
    }

    @IBAction func action(_ sender: Any?) {
        Router.shared?.navigate(to: navigationObject?.link, completion: nil)
    }
}
