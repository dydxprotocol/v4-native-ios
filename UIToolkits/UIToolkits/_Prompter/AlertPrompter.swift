//
//  AlertPrompter.swift
//  UIToolkits
//
//  Created by Qiang Huang on 6/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

open class AlertPrompter: NSObject, PrompterProtocol {
    public var title: String?
    public var message: String?
    public var style: PrompterStyle = .selection
    internal var alertController: UIAlertController?

    public func set(title: String?, message: String?, style: PrompterStyle) {
        self.title = title
        self.message = message
        self.style = style
    }

    private func alertStyle(style: PrompterActionStyle) -> UIAlertAction.Style {
        switch style {
        case .cancel:
            return .cancel

        case .destructive:
            return .destructive

        default:
            return .default
        }
    }

    public func prompt(_ actions: [PrompterAction]) {
        if actions.count > 0 {
            let alert = UIAlertController(title: title, message: message, preferredStyle: (style == .selection) ? .actionSheet : .alert)
            alertController = alert
            for action in actions {
                let alertAction = UIAlertAction(title: action.title, style: alertStyle(style: action.style)) { [weak self] _ in
                    self?.dismiss()
                    action.selection?()
                }
                alert.addAction(alertAction)
            }

            if let barButtonItem = UserInteraction.shared.sender as? UIBarButtonItem {
                alert.popoverPresentationController?.barButtonItem = barButtonItem
            } else if let view = UserInteraction.shared.sender as? UIView {
                alert.popoverPresentationController?.sourceView = view
                alert.popoverPresentationController?.sourceRect = view.bounds
            } else if let viewController = ViewControllerStack.shared?.topmost(), let view = viewController.view {
                alert.popoverPresentationController?.sourceView = view
                alert.popoverPresentationController?.sourceRect = view.bounds
            }
            UserInteraction.shared.sender = nil
            DispatchQueue.main.async {
                ViewControllerStack.shared?.topmost()?.present(alert, animated: true, completion: nil)
            }
        }
    }

    public func dismiss() {
        alertController?.dismiss(nil)
        alertController = nil
    }
}
