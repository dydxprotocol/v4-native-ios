//
//  AbacusLoggingImp.swift
//  dydxStateManager
//
//  Created by Rui Huang on 13/05/2024.
//

import Foundation
import Abacus
import ParticlesKit

final public class AbacusLoggingImp: NSObject, Abacus.LoggingProtocol {
    public func ddInfo(tag: String, message: String, context: [String: Any]?) {
        // TODO:
    }

    public func e(tag: String, message: String, context: [String: Any]?, error: KotlinError?) {
        ErrorLogging.shared?.e(tag: tag, message: message)
    }

    public func e(tag: String, message: String) {
        ErrorLogging.shared?.e(tag: tag, message: message)
    }

    public func d(tag: String, message: String) {
        ErrorLogging.shared?.d(tag: tag, message: message)
    }
}
