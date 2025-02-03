//
//  dydxGainLossInputViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/2/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities
import Popovers

public class dydxGainLossInputViewModel: PlatformViewModeling {

    public enum Unit: CaseIterable {
        case dollars
        case percentage

        var displayText: String {
            switch self {
            case .dollars:
                return "$"
            case .percentage:
                return "%"
            }
        }
    }

    fileprivate let triggerType: dydxTakeProfitStopLossInputAreaModel.TriggerType
    fileprivate let onEdited: ((String?, Unit) -> Void)?

    @Published fileprivate var isFocused: Bool = false
    @Published fileprivate var curUnit: Unit = .percentage {
        didSet {
            updateDisplayText()
        }
    }

    @Published fileprivate var isPresentingUnitOptions: Bool = false

    /// text that is edited by user (or in some cases, programmatically)
    @Published private var dollars: String = ""
    @Published private var percentage: String = ""

    @Published fileprivate var displayText: String = ""

    /// sets the value text for the specified unit, but will not override active edit if user has this input focused
    public func set(value: String, forUnit unit: Unit) {
        switch unit {
        case .dollars:
            dollars = value
        case .percentage:
            percentage = value
        }

        if !isFocused {
            updateDisplayText()
        }
    }

    private func updateDisplayText() {
        switch curUnit {
        case .dollars:
            displayText = dollars
        case .percentage:
            displayText = percentage
        }
    }

    public init(triggerType: dydxTakeProfitStopLossInputAreaModel.TriggerType, onEdited: ((String?, Unit) -> Void)? = nil) {
        self.triggerType = triggerType
        self.onEdited = onEdited
    }

    public func createView(parentStyle: ThemeStyle, styleKey: String?) -> some View {
        dydxGainLossInputView(viewModel: self)
    }
}

/// note, we cannot use PlatformView because this view manages focus which requires using @FocusState which cannot be used for classes. @FocusState is necessary for Popover interaction
struct dydxGainLossInputView: View {

    @FocusState private var isFocused: Bool
    @ObservedObject private var viewModel: dydxGainLossInputViewModel

    fileprivate init(viewModel: dydxGainLossInputViewModel) {
        self.viewModel = viewModel
    }

    var header: some View {
        Text(DataLocalizer.shared?.localize(path: viewModel.triggerType.gainLossInputTitleLocalizerPath, params: nil) ?? "")
            .themeColor(foreground: .textTertiary)
            .themeFont(fontSize: .smaller)
    }

    var placeholder: Text {
        Text("0")
            .foregroundColor(ThemeColor.SemanticColor.textTertiary.color.opacity(0.3))
            .themeFont(fontType: .base, fontSize: .large)
    }

    var textInput: some View {
        let textField = TextField("", text: $viewModel.displayText, prompt: placeholder)
            .themeFont(fontType: .base, fontSize: .large)
            .themeColor(foreground: .textPrimary)
            .keyboardType(.decimalPad)
            .focused($isFocused)
        if #available(iOS 17.0, *) {
            return textField
                .onChange(of: viewModel.displayText) { displayTextOnChange(newValue: $1) }
                .onChange(of: isFocused) { isFocusedOnChange(newValue: $1) }
        } else {
            return textField
                .onChange(of: viewModel.displayText) { displayTextOnChange(newValue: $0) }
                .onChange(of: isFocused) { isFocusedOnChange(newValue: $0) }
        }
    }

    private func displayTextOnChange(newValue: String) {
        guard isFocused else { return }
        if let onEdited = viewModel.onEdited {
            onEdited(newValue, viewModel.curUnit)
        }
    }

    private func isFocusedOnChange(newValue: Bool) {
        viewModel.isFocused = newValue
        viewModel.onEdited?(viewModel.displayText, viewModel.curUnit)
    }

    private var displaySelector: some View {
        Button(action: {
            if !viewModel.isPresentingUnitOptions {
                viewModel.isPresentingUnitOptions = true
            }
            if isFocused {
                isFocused = false
            }
        }, label: {
            Text(viewModel.curUnit.displayText)
                .contentShape(.rect)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(minWidth: 40)
                .themeColor(background: .layer5)
                .cornerRadius(6, corners: .allCorners)
        })
        .popover(present: $viewModel.isPresentingUnitOptions, attributes: { attrs in
                attrs.position = .absolute(
                           originAnchor: .bottom,
                           popoverAnchor: .topLeft
                       )
                attrs.sourceFrameInset = .init(top: 0, left: 0, bottom: -16, right: 0)
                attrs.presentation.animation = .none
                attrs.blocksBackgroundTouches = true
                attrs.onTapOutside = {
                    viewModel.isPresentingUnitOptions = false
                }
            }, view: {
                VStack(spacing: 0) {
                    ForEach(Array(dydxGainLossInputViewModel.Unit.allCases.enumerated()), id: \.element) { index, unit in
                        Button {
                            viewModel.curUnit = unit
                            viewModel.isPresentingUnitOptions = false
                        } label: {
                            Text(unit.displayText)
                                .themeFont(fontSize: .medium)
                                .themeColor(foreground: .textPrimary)
                            .contentShape(Rectangle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }

                        let isLast = index == dydxGainLossInputViewModel.Unit.allCases.count - 1
                        if !isLast {
                            DividerModel().createView()
                        }
                    }
                }
                .fixedSize()
                .makeInput(withBorder: false)
                .environmentObject(ThemeSettings.shared)
            }, background: {
                ThemeColor.SemanticColor.layer0.color.opacity(0.7)
            })
            .wrappedInAnyView()

    }

    public var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                self.header
                self.textInput
            }
            Spacer()
            self.displaySelector
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .makeInput(withBorder: false)
    }
}

#Preview {
    VStack {
        ForEach(dydxTakeProfitStopLossInputAreaModel.TriggerType.allCases, id: \.self) { triggerType in
            dydxGainLossInputViewModel(triggerType: triggerType).createView(parentStyle: .defaultStyle, styleKey: nil)
        }
    }
}
