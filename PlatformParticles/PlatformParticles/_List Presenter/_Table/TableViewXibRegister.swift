//
//  TableViewXibRegister.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/11/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

internal class TableViewXibRegister: NSObject & XibRegisterProtocol {
    public var parallax: Bool = false
    private let kCellName = "TableViewCell"
    private let kParallaxCellName = "ParallaxTableViewCell"
    internal weak var tableView: UITableView?
    internal var registeredXibs: Set<String> = []

    internal func register(xib: String) {
        if parallax {
            if let nib = UINib.safeLoad(xib: kParallaxCellName, bundles: Bundle.particles) {
                tableView?.register(nib, forCellReuseIdentifier: xib)
            }
        } else {
            if let nib = UINib.safeLoad(xib: kCellName, bundles: Bundle.particles) {
                tableView?.register(nib, forCellReuseIdentifier: xib)
            }
        }
    }
}
