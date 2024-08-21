//
//  FormatterProtocols.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 6/10/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

@objc public protocol ValueFormatterProtocol {
    func text(value: Any?) -> String?
    func value(text: String?) -> Any?
}
