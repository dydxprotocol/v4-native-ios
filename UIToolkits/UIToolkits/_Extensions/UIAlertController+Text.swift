//
//  UIAlertViewController+Text.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

public typealias TextInputFunction = (_ text: String?, _ ok: Bool) -> Void

public extension UIAlertController {
    static func prompt(title: String? = nil, message: String? = nil, text: String? = nil, placeholder: String? = nil, completion: @escaping TextInputFunction) {
        var textField: UITextField?

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField { pTextField in
            pTextField.text = text
            pTextField.placeholder = placeholder
            pTextField.clearButtonMode = .whileEditing
            pTextField.borderStyle = .none
            textField = pTextField
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
            completion(nil, false)
        }))

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion(textField?.text, true)
            alertController.dismiss(animated: true, completion: nil)
        }))

        ViewControllerStack.shared?.topmost()?.present(alertController, animated: true, completion: nil)
    }
}
