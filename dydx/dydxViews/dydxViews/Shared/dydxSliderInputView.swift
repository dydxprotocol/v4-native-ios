//
//  dydxSliderInputView.swift
//  dydxViews
//
//  Created by Michael Maguire on 7/18/24.
//

import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities

public class dydxSliderInputViewModel: PlatformViewModel {
    let title: String?
    @Published public var minValue: Double = 0
    @Published public var maxValue: Double = 0
    let formatter: dydxNumberInputFormatter
    @Published public var value: Double = 0 {
        didSet {
            guard value != oldValue else { return }
            value = max(minValue, min(value, maxValue))
        }
    }

    var placeholder: String {
        formatter.string(for: Double.zero) ?? ""
    }

    init(title: String?, formatter: dydxNumberInputFormatter) {
        self.title = title
        self.formatter = formatter
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return PlatformView.emptyView.wrappedInAnyView() }
            return dydxSliderTextInput(viewModel: self).wrappedInAnyView()
        }
    }
}

private struct dydxSliderTextInput: View {
    @ObservedObject var viewModel: dydxSliderInputViewModel

    var slider: some View {
        dydxSlider(minValue: $viewModel.minValue,
                   maxValue: $viewModel.maxValue,
                   value: $viewModel.value)
    }

    var textInput: some View {
        dydxNumberField(title: viewModel.title,
                        placeholder: viewModel.placeholder,
                        formatter: viewModel.formatter,
                        value: $viewModel.value)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            slider
            textInput
                .makeInput()
            // min 114 is the min size and fixed size will allow it to expand to keep title in one line
                .frame(minWidth: 114)
                .fixedSize()
        }
    }
}
