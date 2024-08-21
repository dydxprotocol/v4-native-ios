//
//  TableViewHeaderXibRegister.swift
//  PlatformParticles
//
//  Created by John Huang on 3/8/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import ParticlesKit
import Utilities

internal class TableViewHeaderXibRegister: NSObject & XibRegisterProtocol {
    internal weak var tableView: UITableView?
    internal var registeredXibs: Set<String> = []

    internal func register(xib: String) {
        tableView?.register(XibTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: xib)
    }
}
