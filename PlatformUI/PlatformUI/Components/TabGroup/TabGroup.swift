//
//  TabGroup.swift
//  PlatformUI
//
//  Created by Rui Huang on 10/3/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI

// a View is required here since `matchedGeometryEffect` is used which requires a @Namespace property wrappers for proper functionality. @Namespace properties must exist within the context of a View
private struct TabGroupView<ItemContent: PlatformViewModeling>: View {
    @ObservedObject var model: TabGroupModel<ItemContent>
    @Namespace var animation

    private let parentStyle: ThemeStyle
    private let styleKey: String?
    private let selectionAnimation: Animation?

    init(model: TabGroupModel<ItemContent>, selectionAnimation: Animation?, parentStyle: ThemeStyle, styleKey: String?) {
        self.model = model
        self.parentStyle = parentStyle
        self.styleKey = styleKey
        self.selectionAnimation = selectionAnimation
    }

    public var body: some View {
        HStack(spacing: model.spacing) {
            ForEach(0..<(model.items?.count ?? 0), id: \.self) { i in
                if i == model.currentSelection {
                    selectedItemView(index: i)
                } else {
                    unselectedItemView(index: i)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .animation(selectionAnimation, value: model.currentSelection)
    }

    private func selectedItemView(index: Int) -> some View {
        let item = model.selectedItems?[index]
            .createView(parentStyle: parentStyle, styleKey: model.selectedStyleKey)
            .matchedGeometryEffect(id: index, in: animation)

        return item
            .frameIf(condition: model.layoutConfig == .equalSpacing, minWidth: 0, maxWidth: .infinity)
    }

    private func unselectedItemView(index: Int) -> some View {
        let item = model.items?[index]
            .createView(parentStyle: parentStyle, styleKey: model.unselectedStyleKey)
            .onTapGesture {
                withAnimation(selectionAnimation) {
                    model.currentSelection = index
                }
                model.onSelectionChanged?(index)
            }
            .matchedGeometryEffect(id: index, in: animation)

        return item
            .frameIf(condition: model.layoutConfig == .equalSpacing, minWidth: 0, maxWidth: .infinity)
    }
}

private extension View {
    func frameIf(condition: Bool, minWidth: CGFloat?, maxWidth: CGFloat?) -> some View {
        if condition {
            return AnyView(self.frame(minWidth: minWidth, maxWidth: maxWidth))
        } else {
            return AnyView(self)
        }
    }
}


public class TabGroupModel<ItemContent: PlatformViewModeling> : PlatformViewModel {
    public enum LayoutConfig {
        case naturalSize
        case equalSpacing
    }
    @Published public var items: [ItemContent]?
    @Published public var selectedItems: [ItemContent]?
    @Published public var currentSelection: Int?
    @Published public var unselectedStyleKey: String?
    @Published public var selectedStyleKey: String?
    @Published public var onSelectionChanged: ((Int) ->())?
    @Published public var spacing: CGFloat?
    @Published public var layoutConfig = LayoutConfig.naturalSize
    @Published public var selectionAnimation: Animation?

    public init(items: [ItemContent]? = nil, selectedItems: [ItemContent]? = nil, currentSelection: Int? = nil, unselectedStyleKey: String? = nil, selectedStyleKey: String? = nil, selectionAnimation: Animation? = nil, onSelectionChanged: ((Int) ->())? = nil, spacing: CGFloat? = 8, layoutConfig: LayoutConfig = .naturalSize) {
        self.items = items
        if let selectedItems = selectedItems {
            self.selectedItems = selectedItems
        } else {
            self.selectedItems = items
        }
        self.currentSelection = currentSelection
        self.unselectedStyleKey = unselectedStyleKey
        self.selectedStyleKey = selectedStyleKey
        self.onSelectionChanged = onSelectionChanged
        self.spacing = spacing
        self.layoutConfig = layoutConfig
        self.selectionAnimation = selectionAnimation
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            
            assert(self.items?.count == self.selectedItems?.count)
            
            return AnyView(
                TabGroupView(model: self, selectionAnimation: self.selectionAnimation, parentStyle: parentStyle, styleKey: styleKey)
            )
        }
    }
}

#if DEBUG
struct TabGroup_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared
    
    static var previews: some View {
        Group {
            let items = [
                Text("item 1").wrappedViewModel,
                Text("item 2").wrappedViewModel,
                Text("item 3").wrappedViewModel
            ]
            let selected = [
                Text("item 1").themeColor(foreground: .textTertiary).wrappedViewModel,
                Text("item 2").themeColor(foreground: .textTertiary).wrappedViewModel,
                Text("item 3").themeColor(foreground: .textTertiary).wrappedViewModel
            ]
            
            TabGroupModel(items: items, selectedItems: selected, currentSelection: 1)
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif

