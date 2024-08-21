//
//  NavigationInteractor.swift
//  ParticlesCommonModels
//
//  Created by Qiang Huang on 1/30/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit

@objc public class NavigationInteractor: NSObject, InteractorProtocol {
    @objc public dynamic var entity: ModelObjectProtocol? {
        didSet {
            changeObservation(from: oldValue, to: entity, keyPath: #keyPath(NavigationModelProtocol.children)) { [weak self] _, _, _, _ in
                self?.syncChildren()
            }
            changeObservation(from: oldValue, to: entity, keyPath: #keyPath(NavigationModelProtocol.actions)) { [weak self] _, _, _, _ in
                self?.syncActions()
            }
        }
    }

    @objc public dynamic var navigation: NavigationModelProtocol? {
        get {
            return entity as? NavigationModelProtocol
        }
        set {
            entity = newValue
        }
    }

    @objc public dynamic var children: ListInteractor?
    @objc public dynamic var actions: ListInteractor?

    private func syncChildren() {
        if let children = navigation?.children {
            let list = self.children ?? ListInteractor()
            list.sync(children)
            self.children = list
        } else {
            children = nil
        }
    }

    private func syncActions() {
        if let actions = navigation?.actions {
            let list = self.actions ?? ListInteractor()
            list.sync(actions)
            self.actions = list
        } else {
            actions = nil
        }
    }
}
