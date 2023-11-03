//
//  UXTableView.swift
//  UIToolkits
//
//  Created by John Huang on 10/19/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import UIKit
import Utilities

open class UXTableView: UITableView {
    @IBInspectable var clearFooter: Bool = false {
        didSet {
            if clearFooter != oldValue {
                if clearFooter {
                    if tableFooterView == nil {
                        tableFooterView = clearView
                    }
                } else {
                    if tableFooterView == clearView {
                        tableFooterView = nil
                    }
                }
            }
        }
    }

    private var clearView: UIView = UIView()

    private var debouncer: Debouncer = Debouncer()

    var rowDataBounds: CGRect {
        if numberOfSections <= 0 {
            return CGRect(x: 0, y: 0, width: frame.width, height: 0)
        } else {
            let minRect = rect(forSection: 0)
            let maxRect = rect(forSection: numberOfSections - 1)
            return maxRect.union(minRect)
        }
    }

    fileprivate func resizeFooterView() {
        if let footerView = tableFooterView {
            var newHeight: CGFloat = 0
            let tableFrame = self.frame

            if #available(iOS 10, *) {
                newHeight = tableFrame.size.height - rowDataBounds.height - self.contentInset.bottom - self.contentInset.top
            } else {
                newHeight = tableFrame.size.height - contentSize.height
            }
            if newHeight < 0 {
                newHeight = 0
            }
            let frame = footerView.frame
            if newHeight != frame.height {
                footerView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: newHeight)
            }
        }
    }

    public func updateLayout() {
        if let handler = debouncer.debounce() {
            handler.run({ [weak self] in
                if let self = self {
                    if !self.isDragging {
                        self.beginUpdates()
                        self.endUpdates()
                    }
                }
            }, delay: 0.02)
        }
    }

    override open func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        beginUpdates()
        endUpdates()
    }
}
