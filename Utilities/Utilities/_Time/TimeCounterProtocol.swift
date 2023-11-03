//
//  TimeCounterProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 5/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

@objc public protocol TimeCounterProtocol {
    @objc var on: Bool { get set }
    @objc var time: TimeInterval { get }
}
