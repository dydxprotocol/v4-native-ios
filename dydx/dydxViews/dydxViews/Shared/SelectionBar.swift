//
//  SelectionBar.swift
//  dydxUI
//
//  Created by Rui Huang on 5/3/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SelectionBarModel: PlatformViewModel {
    public struct Item: Equatable {
        public var text: String
        public var isSelected: Bool

        public init(text: String, isSelected: Bool) {
            self.text = text
            self.isSelected = isSelected
        }
    }

    public enum Location {
        case header, content

        var fontType: ThemeFont.FontType {
            switch self {
            case.header:
                return .plus
            case .content:
                return .base
            }
        }

        var fontSize: ThemeFont.FontSize {
            switch self {
            case.header:
                return .larger
            case .content:
                return .large
            }
        }
    }

    @Published public var items: [Item]?
    @Published public var onSelectionChanged: ((Int) -> Void)?
    @Published public var location = Location.content

    public var currentSelectionIndex: Int? {
        items?.firstIndex { $0.isSelected }
    }

    public init() { }

    public static var previewValue: SelectionBarModel {
        let vm = SelectionBarModel()
        vm.items = [
            Item(text: "Item 1", isSelected: true),
            Item(text: "Item 2", isSelected: false)
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = self.items?.compactMap {
                TabItemViewModel(value: .bar(Text($0.text).themeColor(foreground: .textTertiary).themeFont(fontType: self.location.fontType, fontSize: self.location.fontSize).wrappedViewModel),
                                 isSelected: false)
            }
            let selectedItems = self.items?.compactMap {
                TabItemViewModel(value: .bar(Text($0.text).themeColor(foreground: .textSecondary).themeFont(fontType: self.location.fontType, fontSize: self.location.fontSize).wrappedViewModel),
                                 isSelected: true)
            }
             return AnyView(
                HStack {
                    TabGroupModel(items: items,
                                  selectedItems: selectedItems,
                                  currentSelection: self.currentSelectionIndex,
                                  onSelectionChanged: self.onSelectionChanged)
                    .createView(parentStyle: style)
                    .animation(.default)
                }
            )
        }
    }
}

#if DEBUG
struct SelectionBarModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SelectionBarModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SelectionBarModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SelectionBarModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
