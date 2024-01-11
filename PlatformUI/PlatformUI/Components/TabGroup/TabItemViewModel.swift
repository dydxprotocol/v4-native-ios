//
//  TabItemViewModel.swift
//  PlatformUI
//
//  Created by John Huang on 1/11/23.
//

import SwiftUI
import Utilities

public class TabItemViewModel: PlatformViewModel, Equatable {
    public static func == (lhs: TabItemViewModel, rhs: TabItemViewModel) -> Bool {
        lhs.isSelected == rhs.isSelected &&
        lhs.value == rhs.value
    }

    public enum TabItemContent: Equatable {
        case text(String)
        case icon(UIImage)
        case bar(PlatformViewModel)

        public static func ==(lhs: TabItemContent, rhs: TabItemContent) -> Bool {
            switch (lhs, rhs) {
            case let (.text(leftText), .text(rightText)):
                return leftText == rightText
            case let (.icon(leftImage), .icon(rightImage)):
                return leftImage.isEqual(rightImage)
            default:
                return false
            }
        }
    }
    @Published public var value: TabItemContent?
    @Published public var isSelected: Bool = false

    public init(value: TabItemViewModel.TabItemContent? = nil, isSelected: Bool = false) {
        self.value = value
        self.isSelected = isSelected
    }

    public static var previewValue: TabItemViewModel = {
        let vm = TabItemViewModel()
        vm.value = .bar(Text("Test String").wrappedViewModel)
        vm.isSelected = true
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self, let value = self.value else { return AnyView(PlatformView.nilView) }

            let styleKey = self.isSelected ? "pill_tab_group_selected_item" : "pill_tab_group_unselected_item"
            let templateColor: ThemeColor.SemanticColor = self.isSelected ? .textPrimary: .textTertiary
            let borderWidth: CGFloat = 1
            switch value {
            case .text(let value):
                return Text(value)
                    .themeFont(fontSize: .small)
                    .padding([.bottom, .top], 8)
                    .padding([.leading, .trailing], 12)
                    .themeStyle(styleKey: styleKey, parentStyle: style)
                    .borderAndClip(style: .capsule, borderColor: .layer6, lineWidth: borderWidth)
                    .wrappedInAnyView()
            case .icon(let image):
                return PlatformIconViewModel(type: .uiImage(image: image),
                                                    size: CGSize(width: 18, height: 18),
                                                    templateColor: templateColor)
                    .createView(parentStyle: parentStyle)
                    .padding([.bottom, .top], 8)
                    .padding([.leading, .trailing], 12)
                    .themeStyle(styleKey: styleKey, parentStyle: style)
                    .borderAndClip(style: .capsule, borderColor: .layer6, lineWidth: borderWidth)
                    .wrappedInAnyView()
            case .bar(let value):
                let content = VStack {
                    value.createView(parentStyle: style)
                    Rectangle()
                        .fill(self.isSelected ? ThemeColor.SemanticColor.colorPurple.color : .clear)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                return AnyView(content)

            }
        }
    }
}

#if DEBUG
struct TabItem_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
//        ThemeSettings.applyDarkTheme()
//        ThemeSettings.applyStyles()
        return TabItemViewModel.previewValue
            .createView()
            .previewLayout(.sizeThatFits)
    }
}

struct TabItem_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
//        ThemeSettings.applyLightTheme()
//        ThemeSettings.applyStyles()
        return TabItemViewModel.previewValue
            .createView()
            .previewLayout(.sizeThatFits)
    }
}

#endif
