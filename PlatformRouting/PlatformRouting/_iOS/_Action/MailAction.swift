//
//  Mail.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 5/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import MessageUI
import RoutingKit
import UIToolkits
import Utilities

open class MailAction: NSObject, NavigableProtocol, MFMailComposeViewControllerDelegate {
    public var completion: RoutingCompletionBlock?
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.scheme {
        case "mailto":
            mail(request: request, completion: completion)

        default:
            completion?(nil, false)
        }
    }

    open func mail(request: RoutingRequest?, completion: RoutingCompletionBlock?) {
        if MFMailComposeViewController.canSendMail() {
            if let mail = configuredMailComposeViewController(request: request), let topmost = ViewControllerStack.shared?.topmost() {
                self.completion = completion
                topmost.present(mail, animated: true, completion: nil)
                return
            } else {
                self.completion?(nil, false)
            }
        } else {
            self.completion?(nil, false)
        }
    }

    open func configuredMailComposeViewController(request: RoutingRequest?) -> MFMailComposeViewController? {
        if let path = request?.path {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
            mail.setToRecipients([path])
            if let subject = parser.asString(request?.params?["subject"]) {
                mail.setSubject(subject)
            }
            return mail
        }
        return nil
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [weak self] in
            self?.completion?(nil, result == .sent)
        }
    }
}
