//
//  UIActivityIndicatorView+Waiting.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/8/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView: WaitProtocol {
    public var waiting: Bool {
        get {
            return isAnimating
        }
        set {
            if newValue != waiting {
                if newValue {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }
    }
}
