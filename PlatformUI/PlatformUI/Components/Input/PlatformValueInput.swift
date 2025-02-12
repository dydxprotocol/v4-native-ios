//
//  PlatformValueInputViewModel.swift
//  PlatformUI
//
//  Created by Rui Huang on 13/02/2025.
//

import SwiftUI
import Utilities

open class PlatformValueInputViewModel: PlatformViewModel {
    @Published public var label: String?
    open var value: String?
    @Published open var valueAccessoryView: AnyView? {
        didSet {
            updateView()
        }
    }
    @Published open var labelAccessory: AnyView? {
        didSet {
            updateView()
        }
    }

    public var onEdited: ((String?) -> Void)?

    public init(label: String? = nil, labelAccessory: AnyView? = nil, value: String? = nil, valueAccessoryView: AnyView? = nil, onEdited: ((String?) -> Void)? = nil) {
        self.label = label
        self.labelAccessory = labelAccessory
        self.value = value
        self.valueAccessoryView = valueAccessoryView
        self.onEdited = onEdited
    }

    open func valueChanged(value: String?) {
        onEdited?(value)
    }

    open var header: PlatformViewModel {
        if let label = label, label.length > 0 {
            return Text(label)
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .smaller)
                        .wrappedViewModel

        }

        return PlatformView.nilViewModel
    }
}
