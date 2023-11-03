//
//  ErrorAlert.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/9/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities
import Combine

public class ErrorAlert: NSObject, ErrorInfoProtocol, CombineObserving {
    public var cancellableMap = [AnyKeyPath : AnyCancellable]()
    
    public var pending: ErrorInfoData?
    
    public var appState: AppState? {
        didSet {
            didSetAppState(oldValue: oldValue)
        }
    }
    
    public func info(data: ErrorInfoData) {
        if let prompter = PrompterFactory.shared?.prompter() {
            prompter.set(title: data.title, message: self.message(message: data.message, error: data.error), style: .error)
            var promptActions = [PrompterAction]()
            if let actions = data.actions {
                for action in actions {
                    promptActions.append(PrompterAction(title: action.text, style: .normal, selection: {
                        action.handler()
                    }))
                }
                promptActions.append(PrompterAction.cancel())
            } else {
                promptActions.append(PrompterAction.cancel(title: "OK"))
            }
            prompter.prompt(promptActions)
        }
    }

    public func clear() {
    }
}
