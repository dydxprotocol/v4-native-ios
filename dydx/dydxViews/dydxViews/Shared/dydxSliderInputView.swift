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
import Combine

public class dydxSliderInputViewModel: PlatformViewModel {
    public let title: String?
    @Published public var accessoryTitle: String?
    @Published public var minValue: Double = 0
    @Published public var maxValue: Double = 0
    @Published public var precision: Int = 0
    @Published public var value: Double? {
        didSet {
            valueAsString = value.map { numberFormatter.string(from: $0 as NSNumber) ?? "" } ?? ""
        }
    }

    public func setPrecision(_ stepSize: Double) {
        guard stepSize > 0 else {
            assertionFailure("Step size must be greater than 0")
            return
        }
        precision = Int(-log10(stepSize))
    }

    var numberFormatter: dydxNumberInputFormatter {
        dydxNumberInputFormatter(fractionDigits: precision)
    }

    @Published public private(set) var valueAsString: String = ""

    var placeholder: String {
        numberFormatter.string(for: Double.zero) ?? ""
    }

    init(title: String?, accessoryTitle: String? = nil, precision: Int) {
        self.title = title
        self.accessoryTitle = accessoryTitle
        self.precision = precision
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
        dydxTitledNumberField(title: viewModel.title,
                        accessoryTitle: viewModel.accessoryTitle,
                        placeholder: viewModel.placeholder,
                        precision: viewModel.precision,
                        minValue: viewModel.minValue,
                        maxValue: viewModel.maxValue,
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
