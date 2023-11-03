//
//  dydxClosePositionInputPercentView.swift
//  dydxViews
//
//  Created by John Huang on 2/14/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxClosePositionInputPercentViewModel: PlatformOptionsInputViewModel {
    public static var previewValue: dydxClosePositionInputPercentViewModel = {
        var options = [InputSelectOption]()
        options.append(InputSelectOption(value: "0.25", string: "25%"))
        options.append(InputSelectOption(value: "0.50", string: "50%"))
        options.append(InputSelectOption(value: "0.75", string: "75%"))
        options.append(InputSelectOption(value: "1", string: "100%"))
        let vm = dydxClosePositionInputPercentViewModel(label: nil, value: nil, options: options, onEdited: nil)
        return vm
    }()

    private func unselected(item: String) -> PlatformViewModel {
        Text(item)
            .themeFont(fontType: .bold, fontSize: .small)
            .padding(8)
            .themeColor(foreground: .textTertiary)
            .themeColor(background: .layer6)
            .cornerRadius(8)
            .wrappedViewModel
    }

    private func selected(item: String) -> PlatformViewModel {
        Text(item)
            .themeFont(fontType: .bold, fontSize: .small)
            .padding(8)
            .themeColor(background: .layer0)
            .cornerRadius(8)
            .wrappedViewModel
    }

    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let titles = self.optionTitles

            var row1 = titles
            row1?.removeLast()
            let row1Items = row1?.compactMap {
                self.unselected(item: $0)
            }
            let selectedRow1Items = row1?.compactMap {
                self.selected(item: $0)
            }
            var row1Index = self.index
            if let titles = titles, self.index == titles.count - 1 {
                row1Index = nil
            }

            let lastItem = titles?.last
            let row2 = (lastItem != nil) ? [lastItem!] : nil

            let row2Items = row2?.compactMap {
                self.unselected(item: $0)
            }
            let selectedRow2Items = row2?.compactMap {
                self.selected(item: $0)
            }
            var row2Index: Int?
            if let titles = titles, self.index == titles.count - 1 {
                row2Index = 0 // second row has one item
            }

            return AnyView(
                VStack(spacing: 8) {
                    TabGroupModel(items: row1Items,
                                  selectedItems: selectedRow1Items,
                                  currentSelection: row1Index,
                                  onSelectionChanged: { [weak self] index in
                                      if let self = self {
                                          if index < self.options?.count ?? 0 {
                                              self.value = self.options?[index].value
                                              self.onEdited?(self.value)
                                          }
                                      }
                                  },
                                  layoutConfig: .equalSpacing)
                        .createView(parentStyle: style)
                        .frame(minWidth: 0, maxWidth: .infinity)

                    TabGroupModel(items: row2Items,
                                  selectedItems: selectedRow2Items,
                                  currentSelection: row2Index,
                                  onSelectionChanged: { [weak self] index in
                                      if let self = self {
                                          if index < self.options?.count ?? 0 {
                                              self.value = self.options?.last?.value
                                              self.onEdited?(self.value)
                                          }
                                      }
                                  },
                                  layoutConfig: .equalSpacing)
                        .createView(parentStyle: style)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
            )
        }
    }
}

#if DEBUG
    struct dydxClosePositionInputPercentViewModel_Previews_Dark: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyDarkTheme()
            ThemeSettings.applyStyles()
            return dydxClosePositionInputPercentViewModel.previewValue
                .createView()
                .previewLayout(.sizeThatFits)
        }
    }

    struct dydxClosePositionInputPercentViewModel_Previews_Light: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyLightTheme()
            ThemeSettings.applyStyles()
            return dydxClosePositionInputPercentViewModel.previewValue
                .createView()
                .previewLayout(.sizeThatFits)
        }
    }
#endif
