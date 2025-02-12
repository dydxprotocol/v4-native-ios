//
//  PlatformBooleanInput.swift
//  PlatformUI
//
//  Created by Rui Huang on 13/02/2025.
//

import SwiftUI
import Utilities

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
