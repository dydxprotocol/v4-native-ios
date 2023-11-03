//
//  SelectableListInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 9/2/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

@objc open class SelectableListInteractor: ListInteractor, SelectableProtocol {
    @objc public dynamic var isSelected: Bool = false
}
