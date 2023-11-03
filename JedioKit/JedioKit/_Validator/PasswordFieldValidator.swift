//
//  PasswordFieldValidator.swift
//  JedioKit
//
//  Created by Qiang Huang on 7/7/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
#if _iOS || _tvOS
    import Validator

    @objc public class PasswordFieldValidator: NSObject, FieldValidatorProtocol {
        public func validate(field: String?, data: Any?, optional: Bool) -> Error? {
            if let string = data as? String {
                if string.count > 6 {
                    return nil
                } else {
                    let className = self.className()
                    if let field = field?.lowercased() {
                        return NSError(domain: "\(className).password.tooshort", code: 0, userInfo: ["message": "\(field) is too short."])
                    } else {
                        return NSError(domain: "\(className).password.tooshort", code: 0, userInfo: ["message": "Please enter a valid passport."])
                    }
                }
            } else {
                if optional {
                    return nil
                } else {
                    let className = self.className()
                    if let field = field?.lowercased() {
                        return NSError(domain: "\(className).password.missing", code: 0, userInfo: ["message": "Please enter \(field)."])
                    } else {
                        return NSError(domain: "\(className).password.missing", code: 0, userInfo: ["message": "Please enter a password."])
                    }
                }
            }
        }
    }
#endif
