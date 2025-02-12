//
//  PlatformButtonOptionsInput.swift
//  PlatformUI
//
//  Created by Rui Huang on 13/02/2025.
//

import SwiftUI
import Utilities

open class PlatformButtonOptionsInputViewModel: PlatformOptionsInputViewModel {
    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let titles = self.optionTitles

            let items = titles?.compactMap {
                self.unselected(item: $0)
            }
            let selectedItems = titles?.compactMap {
                self.selected(item: $0)
            }
            return AnyView(
                ScrollViewReader { value in
                    ScrollView(.horizontal, showsIndicators: false) {
                        TabGroupModel(items: items,
                                      selectedItems: selectedItems,
                                      currentSelection: self.index,
                                      onSelectionChanged: { [weak self] index in
                            withAnimation(Animation.easeInOut(duration: 0.05)) {
                                value.scrollTo(index)
                                self?.updateSelection(index: index)
                            }
                        })
                        .createView(parentStyle: style)
                        .padding()
                        .animation(.none)
                    }
                }
            )
        }
    }

    open func updateSelection(index: Int) {
        if index < options?.count ?? 0 {
            value = options?[index].value
            onEdited?(value)
        }
    }

    open func unselected(item: String) -> PlatformViewModel {
        Text(item)
            .themeFont(fontType: .plus, fontSize: .largest)
            .themeColor(foreground: .textTertiary)
            .wrappedViewModel
    }

    open func selected(item: String) -> PlatformViewModel {
        Text(item)
            .themeFont(fontType: .plus, fontSize: .largest)
            .wrappedViewModel
    }
}

