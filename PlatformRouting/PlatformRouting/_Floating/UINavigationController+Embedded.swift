//
//  UINavigationController+Embedded.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 1/20/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

extension UINavigationController: EmbeddedDelegate {
    public var floatingEdge: CGFloat? {
        get {
            return (topViewController as? EmbeddedDelegate)?.floatingEdge
        }
        set {
            (topViewController as? EmbeddedDelegate)?.floatingEdge = newValue
        }
    }
}
