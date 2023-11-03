//
//  Models+Ext.swift
//  dydxStateManager
//
//  Created by Rui Huang on 10/2/22.
//

import Foundation
import Abacus
import Utilities

extension ParsingError: Error {
    var localizedDescription: String? {
        if let stringKey = stringKey {
            return DataLocalizer.localize(path: stringKey)
        }
        return message
    }
}

public extension TradeInput {
    var selectedTypeText: String? {
        let typeOptions = options?.typeOptions
        if let selectedType = typeOptions?.first(where: { $0.type == type?.rawValue }), let stringKey = selectedType.stringKey {
            return DataLocalizer.localize(path: stringKey)
        } else {
            return nil
        }
    }
}
