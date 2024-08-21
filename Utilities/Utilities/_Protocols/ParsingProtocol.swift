//
//  ParsingProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 3/25/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

@objc public protocol ParsingProtocol: NSObjectProtocol {
    @objc optional func parse(dictionary: [String: Any])
    @objc optional func parse(array: [Any])
}
