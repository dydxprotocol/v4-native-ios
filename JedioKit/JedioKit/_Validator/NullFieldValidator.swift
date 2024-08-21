//
//  NullFieldValidator.swift
//  JedioKit
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc public class NullFieldValidator: NSObject, FieldValidatorProtocol {
    public func validate(field: String?, data: Any?, optional: Bool) -> Error? {
        if let _ = data as? String {
            return nil
        } else {
            if optional {
                return nil
            } else {
                let className = self.className()
                if let field = field?.lowercased() {
                    return NSError(domain: "\(className).data.missing", code: 0, userInfo: ["message": "Please enter \(field)."])
                } else {
                    return NSError(domain: "\(className).data.missing", code: 0, userInfo: ["message": "Please enter required data."])
                }
            }
        }
    }
}
