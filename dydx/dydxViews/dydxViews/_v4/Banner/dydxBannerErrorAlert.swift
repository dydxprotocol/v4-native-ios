//
//  BannerErrorAlert.swift
//  dydxViews
//
//  Created by Michael Maguire on 10/6/23.
//

import AVFoundation
import ParticlesKit
import SwiftMessages
import UIToolkits
import Utilities
import Combine
import PlatformParticles
import PlatformUI

public class dydxBannerErrorAlert: BannerErrorAlert {

    public override func info(data: ErrorInfoData) {
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
            let type = self.type(type: type, error: error)
            return MessageView.banner(title: title, body: message, type: type)
        }
        return nil
    }
}
