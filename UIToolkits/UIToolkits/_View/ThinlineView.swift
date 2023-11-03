//
//  ThinlineView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/9/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

public class ThinlineView: UIView {
    @IBOutlet var height: NSLayoutConstraint? {
        didSet {
            if height !== oldValue {
                let scale = UIScreen.main.scale
                height?.constant = 1.0 / scale
            }
        }
    }
}
