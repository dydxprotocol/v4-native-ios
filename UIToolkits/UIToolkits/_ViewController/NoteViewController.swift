//
//  NoteViewController.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

public protocol NoteViewControllerDelegate: NSObjectProtocol {
    func entered(_: NoteViewController, note: String?)
}

public class NoteViewController: KeyboardAdjustingViewController {
    public weak var delegate: NoteViewControllerDelegate?
    public var text: String?

    @IBOutlet var textView: UITextView?
    @IBOutlet var doneButton: ButtonProtocol? {
        didSet {
            if doneButton !== oldValue {
                oldValue?.removeTarget()
                doneButton?.addTarget(self, action: #selector(done(_:)))
            }
        }
    }

    @IBOutlet var cancelButton: ButtonProtocol? {
        didSet {
            if cancelButton !== oldValue {
                oldValue?.removeTarget()
                cancelButton?.addTarget(self, action: #selector(dismiss(_:)))
            }
        }
    }

    static public func note(delegate: NoteViewControllerDelegate, text: String?) {
        if let vc = UIViewController.load(storyboard: "NoteEntry") as? NoteViewController {
            vc.text = text
            vc.delegate = delegate
            let nav = UIViewController.navigation(with: vc)
            ViewControllerStack.shared?.topmost()?.present(nav, animated: true, completion: nil)
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView?.text = text
        let doneItem = doneButton as? UIBarButtonItem
        let cancelItem = cancelButton as? UIBarButtonItem
        if let doneItem = doneItem {
            navigationItem.rightBarButtonItem = doneItem
            if let cancelItem = cancelItem {
                navigationItem.leftBarButtonItem = cancelItem
            }
        } else {
            if let cancelItem = cancelItem {
                navigationItem.rightBarButtonItem = cancelItem
            }
        }
        textView?.becomeFirstResponder()
    }

    @IBAction func done(_ sender: Any?) {
        delegate?.entered(self, note: textView?.text)
        dismiss(sender)
    }
}
