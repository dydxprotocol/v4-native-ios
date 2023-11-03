//
//  ObjectEditLinePresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIToolkits
import Utilities

open class ObjectEditLinePresenter: ObjectValueLinePresenter {
    @IBOutlet var textField: UITextField? {
        didSet {
            if textField !== oldValue {
                oldValue?.removeTarget()
                textField?.add(target: self, action: #selector(edit(_:)), for: UIControl.Event.editingChanged)
            }
        }
    }

    private var editDebouncer = Debouncer()

    override open func didSetLineValue(oldValue: Any?) {
        textField?.text = text
    }

    override open func didSetTitle(oldValue: String?) {
        if let titleLabel = titleLabel {
            titleLabel.text = title
        } else {
            textField?.placeholder = title
        }
    }

    @IBAction func edit(_ sender: Any?) {
        let handler = editDebouncer.debounce()
        handler?.run({ [weak self] in
            self?.reallyEdit()
        }, delay: 0.5)
    }

    open func reallyEdit() {
        if let text = textField?.text, text != "" {
            self.text = text
        } else {
            self.text = nil
        }
    }
}
