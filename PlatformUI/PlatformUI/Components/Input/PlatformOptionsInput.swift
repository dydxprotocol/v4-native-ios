//
//  PlatformOptionsInput.swift
//  PlatformUI
//
//  Created by Rui Huang on 13/02/2025.
//

import SwiftUI
import Utilities

public struct InputSelectOption {
    public var value: String
    public var string: String

    public init(value: String, string: String) {
        self.value = value
        self.string = string
    }
}

open class PlatformOptionsInputViewModel: PlatformValueInputViewModel {
    @Published public var options: [InputSelectOption]? // options of values to select from, set at update

    public var optionTitles: [String]? {
        options?.compactMap { $0.string }
    }

    override open var value: String? {
        didSet {
            if value != oldValue {
                index = valueIndex()
                // onEdited?(value)
            }
        }
    }

    @Published public var index: Int?

    public init(label: String? = nil, value: String? = nil, options: [InputSelectOption]? = nil, onEdited: ((String?) -> Void)? = nil) {
        super.init(label: label, value: value, onEdited: onEdited)
        self.options = options
        index = valueIndex()
    }

    internal func valueIndex() -> Int? {
        return options?.firstIndex(where: { option in
            option.value == self.value
        })
    }
}
