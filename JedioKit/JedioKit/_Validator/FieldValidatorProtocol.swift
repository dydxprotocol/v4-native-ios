//
//  FieldValidatorProtocol.swift
//  JedioKit
//
//  Created by Qiang Huang on 7/7/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
#if _iOS || _tvOS
    import Validator
#endif

@objc public protocol FieldValidatorProtocol {
    func validate(field: String?, data: Any?, optional: Bool) -> Error?
}

#if _iOS || _tvOS
    public class TextValidationError: ValidationError {
        public var message: String

        public init(_ message: String) {
            self.message = message
        }
    }
#endif
