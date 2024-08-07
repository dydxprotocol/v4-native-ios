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
        public struct PillConfig {
            var text: String
            var textColor: ThemeColor.SemanticColor
            var backgroundColor: ThemeColor.SemanticColor
            
            public init(text: String, textColor: ThemeColor.SemanticColor, backgroundColor: ThemeColor.SemanticColor) {
                self.text = text
                self.textColor = textColor
                self.backgroundColor = backgroundColor
            }
        }
        
        case text(String, EdgeInsets = EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
        case textWithPillAccessory(text: String, pillConfig: PillConfig)
        case icon(UIImage)
        case bar(PlatformViewModel)
        
        public static func ==(lhs: TabItemContent, rhs: TabItemContent) -> Bool {
            switch (lhs, rhs) {
            case let (.text(leftText, leftInsets), .text(rightText, rightInsets)):
                return leftText == rightText && leftInsets == rightInsets
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
            let textFontSize = ThemeFont.FontSize.small
            let borderWidth: CGFloat = 1
            switch value {
            case .text(let value, let edgeInsets):
                return Text(value)
                    .themeFont(fontSize: textFontSize)
                    .padding(edgeInsets)
                    .themeStyle(styleKey: styleKey, parentStyle: style)
                    .borderAndClip(style: .capsule, borderColor: .layer6, lineWidth: borderWidth)
                    .wrappedInAnyView()
            case .textWithPillAccessory(let text, let pillConfig):
                return HStack(alignment: .center, spacing: 4) {
                    Text(text)
                        .themeFont(fontSize: textFontSize)
                        .themeColor(foreground: .textSecondary)
                    Text(pillConfig.text)
                        .themeFont(fontSize: .smaller)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .themeColor(foreground: pillConfig.textColor)
                        .themeColor(background: pillConfig.backgroundColor)
                        .clipShape(.rect(cornerRadius: 6))
                }
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                .themeStyle(styleKey: styleKey, parentStyle: style)
                .borderAndClip(style: .capsule, borderColor: .layer6, lineWidth: borderWidth)
                .wrappedInAnyView()
            case .icon(let image):
                let height = ThemeSettings.shared.themeConfig.themeFont.uiFont(of: .base, fontSize: textFontSize)?.lineHeight ?? 14
                return PlatformIconViewModel(type: .uiImage(image: image),
                                                    size: CGSize(width: height, height: height),
                                                    templateColor: templateColor)
                    .createView(parentStyle: parentStyle)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
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
