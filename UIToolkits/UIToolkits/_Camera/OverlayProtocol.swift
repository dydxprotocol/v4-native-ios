//
//  OverlayProtocol.swift
//  UIToolkits
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc public protocol OverlayProtocol: NSObjectProtocol {
    func layer(rect: CGRect) -> CALayer?
}
