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
struct PlatformInputView: View {
    @ObservedObject private var model: PlatformInputModel
    @FocusState private var isFocused: Bool
    
    private let parentStyle: ThemeStyle
    private let styleKey: String?

    @State private var textRect = CGRect()
 
    init(model: PlatformInputModel, parentStyle: ThemeStyle = ThemeStyle.defaultStyle.themeFont(fontType: .number, fontSize: .large), styleKey: String?) {
        self.model = model
        self.parentStyle = parentStyle
        self.styleKey = styleKey
        self.isFocused = model.isFocused
    }

    var body: some View {
        let alignment: Alignment
        switch model.textAlignment {
            case .leading:
            alignment = .leading
        case .trailing:
            alignment = .trailing
        default:
            alignment = .center
        }
        return HStack(alignment: .center, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                header
                ZStack(alignment: alignment) {
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
        .if(model.twoWayBinding) { content in
            content
                .onChange(of: isFocused) {
                    model.isFocused = $0
                }
        }
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
        let textField = TextField("", text: model.value, onEditingChanged: { editingChanged in
            //isFocused = editingChanged
            model.onEditingChanged?(editingChanged)
        })
            .multilineTextAlignment(model.textAlignment)
            .focused($isFocused)
            .truncationMode(model.truncateMode)
            .keyboardType(model.keyboardType)
            .textContentType(model.contentType)
            .themeColor(foreground: .textPrimary)
            .themeStyle(style: parentStyle)
        
        // currentValue is used to measure the textField width
        var currentValue = model.currentValueRaw ?? ""
        if currentValue == "" {
            currentValue = model.placeHolder
        }

        return Group {
            if model.dynamicWidth {
                ZStack {
                    Text(currentValue)
                        .background(GlobalGeometryGetter(rect: $textRect))
                        .layoutPriority(1)
                        .opacity(0)
                    HStack {
                        textField
                            .frame(width: textRect.width)
                    }
                }
            } else {
                textField
            }
        }
    }

    private var placeholder: some View {
        Text(model.placeHolder)
            .themeColor(foreground: .textTertiary)
            .opacity(0.3)
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
        }.wrappedInAnyView()
    }
}

struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}


public class PlatformInputModel: PlatformViewModel {
    @Published public var label: String?
    @Published public var labelAccessory: AnyView?
    @Published public var value: Binding<String>
    @Published public var valueAccessory: AnyView?
    @Published public var currentValue: String?
    @Published public var currentValueRaw: String?
    @Published public var placeHolder: String = ""
    @Published public var keyboardType: UIKeyboardType = .default
    @Published public var contentType: UITextContentType?
    @Published public var onEditingChanged: ((Bool) -> Void)?
    @Published public var truncateMode: Text.TruncationMode = .tail
    @Published public var focusedOnAppear: Bool = false
    @Published public var isFocused: Bool = false
    @Published public var twoWayBinding: Bool = false
    @Published public var textAlignment: TextAlignment = .leading
    @Published public var dynamicWidth: Bool = false
  
    public init(label: String? = nil,
                labelAccessory: AnyView? = nil,
                value: Binding<String>,
                valueAccessory: AnyView? = nil,
                currentValue: String? = nil,
                currentValueRaw: String? = nil,
                placeHolder: String = "",
                keyboardType: UIKeyboardType = .default,
                contentType: UITextContentType? = nil,
                onEditingChanged: ((Bool) -> Void)? = nil,
                truncateMode: Text.TruncationMode = .tail,
                focusedOnAppear: Bool = false,
                isFocused: Bool = false,
                twoWayBinding: Bool = false,
                textAlignment: TextAlignment = .leading,
                dynamicWidth: Bool = false) {
        self.label = label
        self.labelAccessory = labelAccessory
        self.value = value
        self.valueAccessory = valueAccessory
        self.currentValue = currentValue
        self.currentValueRaw = currentValueRaw
        self.placeHolder = placeHolder
        self.keyboardType = keyboardType
        self.contentType = contentType
        self.onEditingChanged = onEditingChanged
        self.truncateMode = truncateMode
        self.focusedOnAppear = focusedOnAppear
        self.isFocused = isFocused
        self.twoWayBinding = twoWayBinding
        self.textAlignment = textAlignment
        self.dynamicWidth = dynamicWidth
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
