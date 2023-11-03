//
//  AbacusUtils.swift
//  dydxPresenters
//
//  Created by John Huang on 1/11/23.
//

import Abacus
import PlatformUI
import Utilities

class AbacusUtils {
    static func translate(options: [SelectionOption]) -> [InputSelectOption] {
        Array(options).map { option in
            InputSelectOption(value: option.type, string: option.localizedString ?? "")
        }
    }
}

extension [ErrorParam] {
    var dictionary: [String: String] {
        var keyValues = [String: String]()
        for param in self {
            if let value = param.value {
                keyValues[param.key] = value
            }
        }
        return keyValues
    }
}

extension ErrorString {
    var localizedString: String? {
        localized ?? DataLocalizer.localize(path: stringKey, params: params?.dictionary)
    }
}

extension SelectionOption {
    var localizedString: String? {
        if let string = string {
            return string
        } else if let stringKey = stringKey {
            return DataLocalizer.localize(path: stringKey, params: nil)
        }
        return nil
    }
}
