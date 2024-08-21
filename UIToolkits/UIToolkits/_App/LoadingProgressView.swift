//
//  LoadingProgressView.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/24/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import MaterialActivityIndicator
import UIKit
import Utilities

open class LoadingProgressView: UIView, LoadingIndicatorProtocol {
    @IBOutlet var indicator: MaterialActivityIndicatorView?

    private var animating: Bool = false {
        didSet {
            if animating != oldValue {
                if animating {
                    indicator?.startAnimating()
                } else {
                    indicator?.stopAnimating()
                }
            }
        }
    }

    public var status: LoadingStatusProtocol? {
        didSet {
            changeObservation(from: oldValue, to: status, keyPath: #keyPath(LoadingStatusProtocol.running)) { [weak self] _, _, _, _ in
                self?.update()
            }
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        status = LoadingStatus.shared
    }

    open func update() {
        if status?.running ?? false {
            animating = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.animating = self?.status?.running ?? false
            }
        }
    }
}
