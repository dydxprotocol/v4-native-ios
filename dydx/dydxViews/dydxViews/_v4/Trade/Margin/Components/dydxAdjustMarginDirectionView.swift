//
//  dydxAdjustMarginDirectionView.swift
//  dydxUI
//
//  Created by Rui Huang on 09/05/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAdjustMarginDirectionViewModel: PlatformViewModel {
    public enum MarginDirection: String {
        case add = "Add", remove = "Remove"

        var index: Int {
            switch self {
            case .add:
                return 0
            case .remove:
                return 1
            }
        }

        init(index: Int) {
            switch index {
            case 0:
                self = .add
            case 1:
                self = .remove
            default:
                self = .add
            }
        }
    }

    @Published public var marginDirection: MarginDirection = .add
    @Published public var marginDirectionAction: ((MarginDirection) -> Void)?

    public init() { }

    public static var previewValue: dydxAdjustMarginDirectionViewModel {
        let vm = dydxAdjustMarginDirectionViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let marginDirectionTexts = [
                DataLocalizer.localize(path: "APP.TRADE.ADD_MARGIN"),
                DataLocalizer.localize(path: "APP.TRADE.REMOVE_MARGIN")
            ]
            let edgeInsets = EdgeInsets(top: 9, leading: 12, bottom: 9, trailing: 12)
            let items = marginDirectionTexts.compactMap {
                TabItemViewModel(value: .text($0, edgeInsets), isSelected: false)
            }
            let selectedItems = marginDirectionTexts.compactMap {
                TabItemViewModel(value: .text($0, edgeInsets), isSelected: true)
            }
            let view = ScrollView(.horizontal, showsIndicators: false) {
                TabGroupModel(items: items,
                              selectedItems: selectedItems,
                              currentSelection: self.marginDirection.index,
                              onSelectionChanged: { index in
                     self.marginDirectionAction?(MarginDirection(index: index))
                })
                .createView(parentStyle: style)
            }

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxAdjustMarginDirectionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginDirectionViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAdjustMarginDirectionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAdjustMarginDirectionViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
