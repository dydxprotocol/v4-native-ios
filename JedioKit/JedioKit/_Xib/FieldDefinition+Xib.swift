//
//  XibFieldOutputDefinition.swift
//  FieldPresenterLib
//
//  Created by Qiang Huang on 10/16/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

extension FieldDefinition {
    public var xib: String? {
        return parser.asString(data?["xib"])
    }
}
