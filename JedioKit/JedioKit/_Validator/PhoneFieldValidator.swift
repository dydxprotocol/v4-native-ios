//
//  PhoneFieldValidator.swift
//  JedioKit
//
//  Created by John Huang on 7/7/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities
#if _iOS || _tvOS
    import libPhoneNumber_iOS

    @objc public class PhoneFieldValidator: NSObject, FieldValidatorProtocol {
        public func validate(field: String?, data: Any?, optional: Bool) -> Error? {
            if let string = data as? String {
                let phoneUtil = NBPhoneNumberUtil()
                do {
                    let phoneNumber: NBPhoneNumber = try phoneUtil.parse(string, defaultRegion: "US")
                    let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .E164)

                    NSLog("[%@]", formattedString)
                    return nil
                } catch let error as NSError {
                    Console.shared.log(error.localizedDescription)
                }
                let className = self.className()
                if let field = field?.lowercased() {
                    return NSError(domain: "\(className).phone.invalid", code: 0, userInfo: ["message": "Please enter a valid \(field)."])
                } else {
                    return NSError(domain: "\(className).phone.invalid", code: 0, userInfo: ["message": "Please enter a valid phone number."])
                }
            } else {
                if optional {
                    return nil
                } else {
                    let className = self.className()
                    if let field = field?.lowercased() {
                        return NSError(domain: "\(className).phone.missing", code: 0, userInfo: ["message": "Please enter \(field)."])
                    } else {
                        return NSError(domain: "\(className).phone.missing", code: 0, userInfo: ["message": "Please enter a phone number."])
                    }
                }
            }
        }
    }
#endif
