//
//  PlatformTextInput.swift
//  PlatformUI
//
//  Created by Rui Huang on 13/02/2025.
//

import SwiftUI
import Utilities

open class PlatformTextInputViewModel: PlatformValueInputViewModel {
    public enum InputType {
        case `default`
        case decimalDigits
        case wholeNumber

        fileprivate var keyboardType: UIKeyboardType {
            switch self {
            case .default: return .default
            case .decimalDigits: return .decimalPad
            case .wholeNumber: return .numberPad
            }
        }

        fileprivate var sanitize: (String) -> String? {
            switch self {
            case .default: return { $0 }
            case .decimalDigits: return { $0.cleanAsDecimalNumber() }
            case .wholeNumber: return { $0.truncateToWholeNumber() }
            }
        }
    }

    private var debouncer = Debouncer()

    open private(set) var inputType: InputType

    /// Prefer to set `value` directly if forcing is not needed
    /// - Parameters:
    ///   - value: value to set
    ///   - shouldForce: whether setting shoudl happen even if input is focused
    /// we need to refactor how we do inputs to be more flexible
    public final func programmaticallySet(value: String) {
        input = value
        self.valueChanged(value: self.input)
        updateView()
    }

    override open var value: String? {
        didSet {
            if !focused {
                input = value ?? ""
                updateView()
            }
        }
    }

    open override func valueChanged(value: String?) {
        let handler = debouncer.debounce()
        handler?.run({ [weak self] in
            self?.onEdited?(value)
        }, delay: 0.25)
    }

    @Published private var input: String = ""

    @Published private var rawInput: String = ""
    
    public lazy var inputBinding = Binding(
        get: {
            return self.input
        },
        set: { newInput in
            self.rawInput = newInput
            if self.focused {
                let sanitized = self.inputType.sanitize(newInput)
                if let sanitized {
                    self.input = sanitized
                } else if newInput.isEmpty {
                    self.input = ""
                } else {
                    // this is necessary to make binding work properly
                    self.input = self.input
                }
                self.valueChanged(value: self.input)
            }
        }
    )

    @Published public var placeHolder: String?
    private var focused: Bool = false {
        didSet {
            if focused != oldValue {
                if !focused {
                    input = value ?? ""
                }
            }
        }
    }

    public var contentType: UITextContentType?

    private let truncateMode: Text.TruncationMode
    private let focusedOnAppear: Bool
    private let twoWayBinding: Bool
    private let textAlignment: TextAlignment
    private let dynamicWidth: Bool
    
    @Published public var isFocused: Bool = false
    
    public init(label: String? = nil,
                labelAccessory: AnyView? = nil,
                value: String? = nil,
                placeHolder: String? = nil,
                valueAccessoryView: AnyView? = nil,
                inputType: InputType = .default,
                contentType: UITextContentType? = nil,
                onEdited: ((String?) -> Void)? = nil,
                truncateMode: Text.TruncationMode = .middle,
                focusedOnAppear: Bool = false,
                twoWayBinding: Bool = false,
                textAlignment: TextAlignment = .leading,
                dynamicWidth: Bool = false) {
        self.inputType = inputType
        self.truncateMode = truncateMode
        self.focusedOnAppear = focusedOnAppear
        self.twoWayBinding = twoWayBinding
        self.textAlignment = textAlignment
        self.dynamicWidth = dynamicWidth
        super.init(label: label, labelAccessory: labelAccessory, valueAccessoryView: valueAccessoryView, onEdited: onEdited)
        self.value = value
        input = value ?? ""
        self.placeHolder = placeHolder
        self.contentType = contentType
    }
    
    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let model = PlatformInputModel(
                label: self.label,
                labelAccessory: self.labelAccessory,
                value: self.inputBinding,
                valueAccessory: self.valueAccessoryView,
                currentValue: self.input,
                currentValueRaw: self.rawInput,
                placeHolder: self.placeHolder ?? "",
                keyboardType: self.inputType.keyboardType,
                onEditingChanged: { focused in
                    self.focused = focused
                },
                truncateMode: truncateMode,
                focusedOnAppear: focusedOnAppear,
                isFocused: isFocused,
                twoWayBinding: twoWayBinding,
                textAlignment: textAlignment,
                dynamicWidth: dynamicWidth
            )
            
            return AnyView(PlatformInputView(model: model,
                                             parentStyle: parentStyle,
                                             styleKey: styleKey))
        }
    }
}
