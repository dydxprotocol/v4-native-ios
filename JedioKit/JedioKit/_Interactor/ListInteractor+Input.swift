//
//  FieldInputListInteractor.swift
//  JedioKit
//
//  Created by Qiang Huang on 7/7/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit

extension ListInteractor {
    public func validateInput() -> Error? {
        let invalidField = list?.first(where: { (item) -> Bool in
            if let fieldInput = item as? FieldInput {
                return fieldInput.validate() == nil
            } else {
                return false
            }
        })
        return (invalidField as? FieldInput)?.validate()
    }
}
