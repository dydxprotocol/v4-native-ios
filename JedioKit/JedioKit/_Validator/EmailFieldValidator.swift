//
//  EmailFieldValidator.swift
//  JedioKit
//
//  Created by Qiang Huang on 7/7/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
#if _iOS || _tvOS
    import Validator

    @objc public class EmailFieldValidator: NSObject, FieldValidatorProtocol {
        public func validate(field: String?, data: Any?, optional: Bool) -> Error? {
            if let string = data as? String {
                let validationError = TextValidationError("Invalid email")
                let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: validationError)
                if string.validate(rule: emailRule) == .valid {
                    return nil
                } else {
                    let className = self.className()
                    if let field = field?.lowercased() {
                        return NSError(domain: "\(className).email.invalid", code: 0, userInfo: ["message": "Please enter a valid \(field)."])
                    } else {
                        return NSError(domain: "\(className).email.invalid", code: 0, userInfo: ["message": "Please enter a valid email."])
                    }
                }
            } else {
                if optional {
                    return nil
                } else {
                    let className = self.className()
                    if let field = field?.lowercased() {
                        return NSError(domain: "\(className).email.missing", code: 0, userInfo: ["message": "Please enter \(field)."])
                    } else {
                        return NSError(domain: "\(className).email.invalid", code: 0, userInfo: ["message": "Please enter an email."])
                    }
                }
            }
        }
    }
#endif
