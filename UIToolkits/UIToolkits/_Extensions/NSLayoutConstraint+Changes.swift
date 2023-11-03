//
//  NSLayoutConstraint+Changes.swift
//  UIToolkits
//
//  Created by Qiang Huang on 3/6/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import UIKit

public extension NSLayoutConstraint {
    /**
      Change multiplier constraint

      - parameter multiplier: CGFloat
      - returns: NSLayoutConstraint
     */
    func set(multiplier: CGFloat) -> NSLayoutConstraint {
        if let firstItem = firstItem {
            NSLayoutConstraint.deactivate([self])

            let newConstraint = NSLayoutConstraint(
                item: firstItem,
                attribute: firstAttribute,
                relatedBy: relation,
                toItem: secondItem,
                attribute: secondAttribute,
                multiplier: multiplier == 0 ? 0.001 : multiplier,   // to get around some OS bug
                constant: constant)

            newConstraint.priority = priority
            newConstraint.shouldBeArchived = shouldBeArchived
            newConstraint.identifier = identifier

            NSLayoutConstraint.activate([newConstraint])
            return newConstraint
        }
        return self
    }
}
