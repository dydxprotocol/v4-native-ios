//
//  TooltipManager.swift
//  UIToolkits
//
//  Created by John Huang on 1/19/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import EasyTipView
import UIKit

@objc public class TooltipManager: NSObject {
    public static var shared = TooltipManager()

    public var preferences: EasyTipView.Preferences = {
        var pref = EasyTipView.Preferences()
        pref.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        return pref
    }()

    public func show(from: UIView?, superview: UIView? = nil, text: String?) {
        if let from = from, let text = text {
            EasyTipView.show(forView: from, withinSuperview: superview, text: text, preferences: preferences, delegate: nil)
        }
    }
}
