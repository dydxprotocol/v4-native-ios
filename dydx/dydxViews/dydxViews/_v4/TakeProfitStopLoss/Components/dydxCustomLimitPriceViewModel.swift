//
//  dydxCustomLimitPriceViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/2/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities

public class dydxCustomLimitPriceViewModel: PlatformViewModel {

    @Published private var isOn: Bool = false
    @Published public var takeProfitPriceInputViewModel: dydxPriceInputViewModel?
    @Published public var stopLossPriceInputViewModel: dydxPriceInputViewModel?

    @Published private var isTooltipPresented: Bool = false
    private lazy var isTooltipPresentedBinding = Binding(
        get: { [weak self] in self?.isTooltipPresented == true },
        set: { [weak self] in self?.isTooltipPresented = $0 }
    )

    private var onOffSwitch: PlatformView {
        PlatformBooleanInputViewModel(label: DataLocalizer.shared?.localize(path: "APP.TRADE.LIMIT_PRICE", params: nil), labelAccessory: nil, value: isOn.description, valueAccessoryView: nil) { [weak self] value in
            guard let self, let value, let isOn = Bool(value) else { return }
            self.isOn = isOn
        }
        .createView()
    }

    private var input: AnyView? {
        guard isOn else { return nil }
        return super.createView()
            .makeInput()
            .wrappedInAnyView()
    }

    public static var previewValue: dydxPriceInputViewModel = {
        let vm = dydxPriceInputViewModel(title: "TP Limit")
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return PlatformView.emptyView.wrappedInAnyView() }
            return VStack(spacing: 15) {
                self.onOffSwitch
                HStack(alignment: .center, spacing: 20) {
                    if self.isOn {
                        self.takeProfitPriceInputViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                        self.stopLossPriceInputViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                    }
                }
            }
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxCustomLimitPriceViewModel_Previews: PreviewProvider {
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
