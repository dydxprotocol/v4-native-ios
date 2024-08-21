//
//  FloatingLayoutProviderProtocol.swift
//  UIToolkits
//
//  Created by Qiang Huang on 4/30/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import FloatingPanel
import UIKit

public protocol FloatingLayoutProviderProtocol {
    func floatingLayout(traitCollection: UITraitCollection) -> FloatingPanelLayout?
}
