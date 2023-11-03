//
//  ConfirmAction.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

open class ConfirmAction: NSObject, NavigableProtocol {
    open var confirmation: PrompterProtocol?
    public var completion: RoutingCompletionBlock?

    deinit {
        confirmation?.dismiss()
        complete(successful: false)
    }

    @objc open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        if request?.path == "/confirm" {
            let title = parser.asString(request?.params?["title"])
            let text = parser.asString(request?.params?["text"])
            let confirm = parser.asString(request?.params?["confirm"])
            self.confirm(title: title, text: text, confirm: confirm, completion: completion)
        } else {
            completion?(nil, false)
        }
    }

    open func confirm(title: String?, text: String?, confirm: String?, completion: RoutingCompletionBlock?) {
        if text != nil || title != nil, let prompter = PrompterFactory.shared?.prompter() {
            prompter.set(title: title, message: text, style: .error)
            self.completion = completion
            var actions = [PrompterAction]()
            actions.append(PrompterAction(title: confirm ?? "Yes", style: .destructive, enabled: true, selection: { [weak self] in
                self?.complete(successful: true)
            }))
            actions.append(PrompterAction(title: "Cancel", style: .cancel, enabled: true, selection: { [weak self] in
                self?.complete(successful: false)
            }))
            prompter.prompt(actions)
            confirmation = prompter
        } else {
            completion?(nil, false)
        }
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
