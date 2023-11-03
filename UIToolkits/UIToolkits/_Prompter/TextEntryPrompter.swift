//
//  TextEntryPrompter.swift
//  UIToolkits
//
//  Created by Qiang Huang on 6/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

open class TextEntryPrompter: AlertPrompter, TextPrompterProtocol {
    public var placeholder: String?
    public var text: String?

    public func prompt(title: String?, message: String?, text: String?, placeholder: String?, completion: @escaping TextEntrySelection) {
        UIAlertController.prompt(title: title, message: message, text: text, placeholder: placeholder) { text, ok in
            completion(text, ok)
        }
    }
}
