//
//  BannerErrorAlert.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 1/21/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import AVFoundation
import ParticlesKit
import SwiftMessages
import UIToolkits
import Utilities
import Combine

open class BannerErrorAlert: NSObject, ErrorInfoProtocol, CombineObserving {
    public var cancellableMap = [AnyKeyPath : AnyCancellable]()
    
    public var appState: AppState? {
        didSet {
            didSetAppState(oldValue: oldValue)
        }
    }
    
    public var pending: ErrorInfoData?
    
    public func configuration(type: EInfoType?, time: Double?) -> SwiftMessages.Config {
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: .statusBar)
        if let time = time {
            config.duration = .seconds(seconds: time)
        } else {
            config.duration = .forever
        }
        return config
    }

    open func info(data: ErrorInfoData) {
        if let messageView = view(title: data.title, message: data.message, type: data.type, error: data.error) {
            if let actions = data.actions {
                if actions.count == 1 {
                    messageView.button?.isHidden = false
                    if let action = actions.first {
                        messageView.button?.buttonTitle = action.text
                        messageView.buttonTapHandler = { _ in
                            SwiftMessages.hide()
                            action.action(messageView.button)
                        }
                    }
                } else {
                    for action in actions {
                        let button = UIButton()
                        button.buttonTitle = action.text
                        button.addTarget(action, action: #selector(ErrorAction.action(_:)))
                        messageView.addSubview(button)
                    }
                }
            }
            SwiftMessages.hide()
            let config = configuration(type: data.type, time: data.time)
            SwiftMessages.show(config: config, view: messageView)
            if data.error != nil {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }

    private func view(title: String?, message: String?, type: EInfoType?, error: Error?) -> MessageView? {
        let message = self.message(message: message, error: error) ?? error?.localizedDescription
        if title != nil || message != nil {
            let view = MessageView.viewFromNib(layout: .cardView)
            let type = self.type(type: type, error: error)
            switch type {
            case .warning:
                view.configureTheme(.warning)

            case .error:
                view.configureTheme(.error)

            case .success:
                view.configureTheme(.success)

            case .info:
                fallthrough
            case .wait:
                fallthrough
            default:
                view.configureTheme(.info)
            }
            view.configureDropShadow()
            view.configureContent(title: title ?? "", body: message ?? "")
            view.button?.isHidden = true
            return view
        }
        return nil
    }

    public func clear() {
        SwiftMessages.hide()
    }
}
