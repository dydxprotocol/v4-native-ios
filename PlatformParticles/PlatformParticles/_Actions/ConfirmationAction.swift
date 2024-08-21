//
//  ConfirmationAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/21/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

open class ConfirmationAction: NSObject, NavigableProtocol {
    open var confirmation: PrompterProtocol?
    public var completion: RoutingCompletionBlock?

    deinit {
        confirmation?.dismiss()
        complete(successful: false)
    }

    @objc open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        completion?(nil, false)
    }

    open func confirm(confirmation: PrompterProtocol, actions: [PrompterAction], completion: RoutingCompletionBlock?) {
        self.confirmation = confirmation
        var actions = actions
        actions.append(PrompterAction.cancel(selection: { [weak self] in
            self?.complete(successful: false)
        }))
        confirmation.prompt(actions)
    }

    open func complete(successful: Bool) {
        confirmation = nil
        completion?(nil, successful)
        completion = nil
    }
}
