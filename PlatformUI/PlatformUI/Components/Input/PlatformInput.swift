//
//  PlatformInput.swift
//  PlatformUI
//
//  Created by Rui Huang on 9/19/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import Utilities
import Introspect
import Popovers

// a View is required here since programmatically focusing a textView requires a @FocusState property wrapper
private struct PlatformInputView: View {
    @ObservedObject private var model: PlatformInputModel
    @FocusState private var isFocused: Bool

    private var parentStyle: ThemeStyle
    private var styleKey: String?

    init(model: PlatformInputModel, parentStyle: ThemeStyle = ThemeStyle.defaultStyle.themeFont(fontType: .number, fontSize: .large), styleKey: String?) {
        self.model = model
        self.parentStyle = parentStyle
        self.styleKey = styleKey
    }

    var body: some View {
        return HStack(alignment: .center, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                header
                ZStack(alignment: .leading) {
                    if model.currentValue == nil || model.currentValue?.length == 0 {
                        placeholder
                    }
                    textField
                }
            }
            model.valueAccessory
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onChange(of: model.isFocused) {
            isFocused = $0
        }
//        .onChange(of: isFocused) {
//            model.isFocused = $0
//        }
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            if model.focusedOnAppear {
                isFocused = true
            }
        }
    }

    private var fontType: ThemeFont.FontType {
        switch model.keyboardType {
        case .numberPad, .numbersAndPunctuation, .decimalPad:
            return .number
        default:
            return .base
        }
    }

    private var textField: some View {
        TextField("", text: model.value, onEditingChanged: { editingChanged in
            isFocused = editingChanged
            model.onEditingChanged?(editingChanged)
        })
        .focused($isFocused)
        .truncationMode(model.truncateMode)
        .keyboardType(model.keyboardType)
        .textContentType(model.contentType)
        .themeColor(foreground: .textPrimary)
        .themeStyle(style: parentStyle)
    }

    private var placeholder: some View {
        Text(model.placeHolder)
            .themeColor(foreground: .textTertiary)
            .themeStyle(style: parentStyle)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .truncationMode(model.truncateMode)
    }

    private var header: AnyView? {
        guard let headerText = model.label else { return nil }
        return HStack(spacing: 4) {
            Text(headerText)
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smaller)
            model.labelAccessory
            Spacer()
        }.wrappedInAnyView()
    }
}

public class PlatformInputModel: PlatformViewModel {
    @Published public var label: String?
    @Published public var labelAccessory: AnyView?
    @Published public var value: Binding<String>
    @Published public var valueAccessory: AnyView?
    @Published public var currentValue: String?
    @Published public var placeHolder: String = ""
    @Published public var keyboardType: UIKeyboardType = .default
    @Published public var contentType: UITextContentType?
    @Published public var onEditingChanged: ((Bool) -> Void)?
    @Published public var truncateMode: Text.TruncationMode = .tail
    @Published public var focusedOnAppear: Bool = false
    @Published public var isFocused: Bool = false
    
    public init(label: String? = nil,
                labelAccessory: AnyView? = nil,
                value: Binding<String>,
                valueAccessory: AnyView? = nil,
                currentValue: String? = nil,
                placeHolder: String = "",
                keyboardType: UIKeyboardType = .default,
                contentType: UITextContentType? = nil,
                onEditingChanged: ((Bool) -> Void)? = nil,
                truncateMode: Text.TruncationMode = .tail,
                focusedOnAppear: Bool = false,
                isFocused: Bool = false) {
        self.label = label
        self.labelAccessory = labelAccessory
        self.value = value
        self.valueAccessory = valueAccessory
        self.currentValue = currentValue
        self.placeHolder = placeHolder
        self.keyboardType = keyboardType
        self.contentType = contentType
        self.onEditingChanged = onEditingChanged
        self.truncateMode = truncateMode
        self.focusedOnAppear = focusedOnAppear
        self.isFocused = isFocused
    }

    public static var previewValue: PlatformInputModel = {
        let vm = PlatformInputModel(value: Binding(get: { "Test String" }, set: { _ = $0 }))
        return vm
    }()

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            let view = PlatformInputView(model: self, parentStyle: parentStyle, styleKey: styleKey)
            return AnyView(view)
        }
    }
}

// Input

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

    public lazy var inputBinding = Binding(
        get: {
            return self.input
        },
        set: { newInput in
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
                focusedOnAppear: Bool = false) {
        self.inputType = inputType
        self.truncateMode = truncateMode
        self.focusedOnAppear = focusedOnAppear
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
                placeHolder: self.placeHolder ?? "",
                keyboardType: self.inputType.keyboardType,
                onEditingChanged: { focused in
                    self.focused = focused
                },
                truncateMode: truncateMode,
                focusedOnAppear: focusedOnAppear,
                isFocused: isFocused
            )
            
            return AnyView(PlatformInputView(model: model,
                                             parentStyle: parentStyle,
                                             styleKey: styleKey))
        }
    }
}

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

open class PlatformButtonOptionsInputViewModel: PlatformOptionsInputViewModel {
    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let titles = self.optionTitles

            let items = titles?.compactMap {
                self.unselected(item: $0)
            }
            let selectedItems = titles?.compactMap {
                self.selected(item: $0)
            }
            return AnyView(
                ScrollViewReader { value in
                    ScrollView(.horizontal, showsIndicators: false) {
                        TabGroupModel(items: items,
                                      selectedItems: selectedItems,
                                      currentSelection: self.index,
                                      onSelectionChanged: { [weak self] index in
                            withAnimation(Animation.easeInOut(duration: 0.05)) {
                                value.scrollTo(index)
                                self?.updateSelection(index: index)
                            }
                        })
                        .createView(parentStyle: style)
                        .padding()
                        .animation(.none)
                    }
                }
            )
        }
    }

    open func updateSelection(index: Int) {
        if index < options?.count ?? 0 {
            value = options?[index].value
            onEdited?(value)
        }
    }

    open func unselected(item: String) -> PlatformViewModel {
        Text(item)
            .themeFont(fontType: .plus, fontSize: .largest)
            .themeColor(foreground: .textTertiary)
            .wrappedViewModel
    }

    open func selected(item: String) -> PlatformViewModel {
        Text(item)
            .themeFont(fontType: .plus, fontSize: .largest)
            .wrappedViewModel
    }
}

open class PlatformPopoverOptionsInputViewModel: PlatformOptionsInputViewModel {
    @Published public var position = Popover.Attributes.Position.absolute(
        originAnchor: .topRight,
        popoverAnchor: .bottomRight
    )

    @Published private var present: Bool = false

    private lazy var presentBinding = Binding(
        get: { [weak self] in
            self?.present ?? false
        },
        set: { [weak self] in
            self?.present = $0
        }
    )

    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            guard let titles = self.optionTitles else {
                return AnyView(PlatformView.nilView)
            }

            return AnyView(
                Button(action: {  [weak self] in
                    if !(self?.present ?? false) {
                        self?.present = true
                    }
                }, label: {
                    VStack(alignment: .leading, spacing: 4) {
                        self.header.createView(parentStyle: style)
                        self.selectedItemView
                            .createView(parentStyle: style)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                })
                .popover(present: self.presentBinding, attributes: { [weak self] attrs in
                    guard let self = self else {
                        return
                    }
                    attrs.position = self.position
                    attrs.sourceFrameInset.top = -8
                    let animation = Animation.easeOut(duration: 0.2)
                    attrs.presentation.animation = animation
                    attrs.dismissal.animation = animation
                    attrs.rubberBandingMode = .none
                    attrs.blocksBackgroundTouches = true
                    attrs.onTapOutside = {
                        self.present = false
                    }

                }, view: {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(titles.enumerated()), id: \.element) { index, title in
                            Button(action: {
                                if index != self.index {
                                    self.index = index
                                    self.onEdited?(self.options?[index].value)
                                }
                                self.present = false
                            }) {
                                HStack {
                                    Text(title)
                                        .themeFont(fontSize: .medium)
                                        .themeColor(foreground: .textPrimary)
                                    Spacer()
                                    if index == self.index {
                                        PlatformIconViewModel(type: .system(name: "checkmark"), size: CGSize(width: 16, height: 16))
                                            .createView(parentStyle: parentStyle, styleKey: styleKey)
                                    }
                                }
                                .contentShape(Rectangle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            let isLast = index == titles.count - 1
                            if !isLast {
                                DividerModel().createView(parentStyle: style)
                            }
                        }
                    }
                    .frame(maxWidth: 300)
                    .fixedSize()
                    .themeColor(background: .layer3)
                    .cornerRadius(16, corners: .allCorners)
                    .border(cornerRadius: 16)
                    .environmentObject(ThemeSettings.shared)
                }, background: {
                    ThemeColor.SemanticColor.layer0.color.opacity(0.7)
                })

            )
        }
    }

    open var selectedItemView: PlatformViewModel {
        let index = index ?? 0
        if let titles = optionTitles, index < titles.count {
            let selectedText = titles[index]
            return Text(selectedText)
                    .themeFont(fontSize: .medium)
                    .leftAligned()
                    .wrappedViewModel
        }
        return PlatformView.nilViewModel
    }
}

open class PlatformBooleanInputViewModel: PlatformValueInputViewModel {

    open var isEnabled: Bool = true

    open override var header: PlatformViewModel {
        if let label = label, label.length > 0 {
            return Text(label)
                .themeColor(foreground: isEnabled ? .textSecondary : .textTertiary)
                        .themeFont(fontSize: .medium)
                        .wrappedViewModel

        }
        return PlatformView.nilViewModel
    }

    override open var value: String? {
        didSet {
            inputBinding.update()
        }
    }

    public lazy var inputBinding = Binding(
        get: { self.value == "true" },
        set: {
            self.value = $0 ? "true" : "false"
            self.valueChanged(value: self.value)
        }
    )

    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: 0) {
                    self.header.createView(parentStyle: style)
                    Spacer()
                    Toggle("", isOn: self.inputBinding)
                        .toggleStyle(SwitchToggleStyle(tint: ThemeColor.SemanticColor.colorPurple.color))
                        .disabled(!self.isEnabled)
                }
            )
        }
    }
}

public extension String {
    var unlocalizedNumericValue: String? {
        Parser.standard.asInputNumber(self)?.stringValue ?? self
    }
}

#if DEBUG
    struct PlatformInput_Previews: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            Group {
                PlatformInputModel.previewValue
                    .createView()
                    .environmentObject(themeSettings)
                    .previewLayout(.sizeThatFits)
            }
        }
    }
#endif
