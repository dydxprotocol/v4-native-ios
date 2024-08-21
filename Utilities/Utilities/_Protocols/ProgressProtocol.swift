//
//  ProgressProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 9/1/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

@objc public protocol ProgressProtocol: NSObjectProtocol {
    @objc var started: Bool { get set }
    @objc var error: Error? { get set }
    @objc var progress: Float { get set }
    @objc var text: String? { get set }
}
