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

    @Published fileprivate var isFocused: Bool = false
    @Published fileprivate var triggerType: dydxTakeProfitStopLossInputAreaModel.TriggerType
    @Published fileprivate var curUnit: Unit = .percentage
    @Published fileprivate var onEdited: ((String?, Unit) -> Void)?
    @Published fileprivate var isPresentingUnitOptions: Bool = false

    @Published fileprivate var dollars: String = ""
    @Published fileprivate var percentage: String = ""

    fileprivate var displayText: String {
        switch curUnit {
        case .dollars:
            return dollars
        case .percentage:
            return percentage
        }
    }

    /// Attempts to set the value for the unit. Will not set if actively editing/has focus.
    public func programmaticallySet(value: String, forUnit unit: Unit) {
        switch unit {
        case .dollars:
            dollars = value
        case .percentage:
            percentage = value
        }
    }

    public func clear() {
        dollars = ""
        percentage = ""
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
    @State private var text: String
    @ObservedObject private var viewModel: dydxGainLossInputViewModel

    fileprivate init(viewModel: dydxGainLossInputViewModel) {
        self.viewModel = viewModel
        switch viewModel.curUnit {
            case .dollars:
                text = viewModel.dollars
            case .percentage:
                text = viewModel.percentage
        }
    }

    var header: some View {
        Text(DataLocalizer.shared?.localize(path: viewModel.triggerType.gainLossInputTitleLocalizerPath, params: nil) ?? "")
            .themeColor(foreground: .textTertiary)
            .themeFont(fontSize: .smaller)
    }

    var placeholder: Text {
        Text("0")
            .themeColor(foreground: .textTertiary)
            .themeFont(fontType: .number, fontSize: .large)
    }

    var textInput: some View {
        let textField = TextField("", text: $text, prompt: placeholder)
            .themeFont(fontType: .number, fontSize: .large)
            .themeColor(foreground: .textPrimary)
            .keyboardType(.decimalPad)
            .focused($isFocused)
        if #available(iOS 17.0, *) {
            return textField
                .onChange(of: text) { _, newValue in
                    // only propagate updates if they are from user editing
                    guard isFocused else { return }
                    viewModel.onEdited?(newValue, viewModel.curUnit)
                }
                .onChange(of: viewModel.displayText) { _, newValue in
                    // do not overwrite user entry while user is editing
                    guard !isFocused else { return }
                    text = newValue
                }
                .onChange(of: isFocused) { _, newValue in
                    viewModel.isFocused = newValue
                    viewModel.onEdited?(text, viewModel.curUnit)
                }
        } else {
            return textField
                .onChange(of: text) { newValue in
                    viewModel.onEdited?(newValue, viewModel.curUnit)
                }
                .onChange(of: isFocused) { newValue in
                    viewModel.isFocused = newValue
                    viewModel.onEdited?(text, viewModel.curUnit)
                }
        }
    }

    var displaySelector: some View {
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
                .borderAndClip(style: .cornerRadius(6), borderColor: .borderDefault)
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
                .themeColor(background: .layer3)
                .borderAndClip(style: .cornerRadius(8), borderColor: .borderDefault)
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
        .makeInput()
    }
}

#Preview {
    VStack {
        ForEach(dydxTakeProfitStopLossInputAreaModel.TriggerType.allCases, id: \.self) { triggerType in
            dydxGainLossInputViewModel(triggerType: triggerType).createView(parentStyle: .defaultStyle, styleKey: nil)
        }
    }
}
