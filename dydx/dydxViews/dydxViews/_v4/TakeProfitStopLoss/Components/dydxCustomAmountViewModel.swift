//
//  dydxCustomAmountViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/2/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities
import Combine

public class dydxCustomAmountViewModel: PlatformViewModel {

    @Published public var isOn: Bool = false
    @Published public var toggleAction: ((Bool) -> Void)?

    public var valuePublisher: AnyPublisher<String?, Never> {
        Publishers.CombineLatest($isOn, sliderTextInput.$valueAsString)
            .map { isOn, value in
                isOn ? value : nil
            }
            .eraseToAnyPublisher()
    }

    @Published public var sliderTextInput = dydxSliderInputViewModel(
        title: DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"),
        precision: 2
    )

    private var onOffSwitch: some View {
        PlatformBooleanInputViewModel(label: DataLocalizer.shared?.localize(path: "APP.GENERAL.CUSTOM_AMOUNT", params: nil), labelAccessory: nil, value: isOn.description, valueAccessoryView: nil) { [weak self] value in
            guard let self, let value, let isOn = Bool(value) else { return }
            self.isOn = isOn
            self.toggleAction?(isOn)
        }
        .createView()
        .padding(.trailing, 2) // swiftui bug where toggle view in a scrollview gets clipped without this
    }

    public static var previewValue: dydxCustomAmountViewModel = {
        let vm = dydxCustomAmountViewModel()
        vm.isOn = true
        vm.sliderTextInput = dydxSliderInputViewModel(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.AMOUNT", params: nil) ?? "",
                                                      accessoryTitle: "ETH",
                                                      precision: 2)
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            // if min == max, there is no need for a custom amount since there can only be one value
            guard let self = self else { return PlatformView.emptyView.wrappedInAnyView() }
            return VStack(spacing: 15) {
                self.onOffSwitch
                HStack(alignment: .center, spacing: 20) {
                    if self.isOn {
                        self.sliderTextInput.createView()
                    }
                }
            }
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxCustomAmountViewModel_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxCustomAmountViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
