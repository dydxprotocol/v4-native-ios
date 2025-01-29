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
    @Published public private(set) var valueAsString: String = ""
    @Published public var value: Double? {
        didSet {
            valueAsString = value.map { numberFormatter.string(from: $0 as NSNumber) ?? "" } ?? ""
        }
    }

    @Published public private(set) var numberFormatter = dydxNumberInputFormatter()

    init(title: String?, accessoryTitle: String? = nil) {
        self.title = title
        self.accessoryTitle = accessoryTitle
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
        dydxSlider(minValue: viewModel.minValue,
                   maxValue: viewModel.maxValue,
                   precision: viewModel.numberFormatter.fractionDigits,
                   value: $viewModel.value)
    }

    var textInput: some View {
        dydxTitledNumberField(title: viewModel.title,
                              accessoryTitle: viewModel.accessoryTitle,
                              numberFormatter: viewModel.numberFormatter,
                              minValue: viewModel.minValue,
                              maxValue: viewModel.maxValue,
                              isMaxButtonVisible: false,
                              withBorder: false,
                              value: $viewModel.value)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            slider
            textInput
                .themeColor(background: .layer3)
                .cornerRadius(12, corners: .allCorners)
            // min 114 is the min size and fixed size will allow it to expand to keep title in one line
                .frame(minWidth: 114)
                .fixedSize()
        }
    }
}
