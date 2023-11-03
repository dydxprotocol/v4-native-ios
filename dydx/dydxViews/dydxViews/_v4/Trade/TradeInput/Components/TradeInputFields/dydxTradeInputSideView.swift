//
//  dydxTradeInputSideView.swift
//  dydxViews
//
//  Created by John Huang on 1/6/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputSideViewModel: PlatformButtonOptionsInputViewModel {
     public static var previewValue: dydxTradeInputSideViewModel = {
        var options = [InputSelectOption]()
        options.append(InputSelectOption(value: "BUY", string: "APP.TRADE.BUY"))
        options.append(InputSelectOption(value: "SELL", string: "APP.TRADE.SELL"))
        let vm = dydxTradeInputSideViewModel(label: nil, value: nil, options: options, onEdited: nil)
        return vm
    }()

    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let titles = self.options?.map { option in
                option.string
            }

            let items = titles?.compactMap {
                BuySellViewModel(text: $0, color: .textTertiary, buttonType: .secondary)
            }
            let selectedItems = self.options?.enumerated().map { (index, item) in
                let color = item.value.uppercased() == "BUY" ? ThemeSettings.positiveColor : ThemeSettings.negativeColor
                return BuySellViewModel(text: titles?[index] ?? "", color: color, buttonType: .primary)
            }
            return AnyView(
                TabGroupModel(items: items,
                              selectedItems: selectedItems,
                              currentSelection: self.index,
                              onSelectionChanged: { [weak self] index in
                                  self?.updateValue(at: index)
                              },
                              layoutConfig: .equalSpacing)
                  .createView(parentStyle: style)
                  .frame(minWidth: 0, maxWidth: .infinity)
            )
        }
    }

    private func updateValue(at index: Int) {
        if index < options?.count ?? 0 {
            value = options?[index].value
            onEdited?(value)
        }
    }
}

#if DEBUG
struct dydxTradeInputSideView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputSideViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputSideView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputSideViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
