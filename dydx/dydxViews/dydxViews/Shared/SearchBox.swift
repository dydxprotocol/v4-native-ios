//
//  SearchBox.swift
//  dydxUI
//
//  Created by Rui Huang on 15/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SearchBoxModel: PlatformViewModel {

    public static var bottomBlendGradiant: LinearGradient {
        let blendedColor = Color(UIColor.blend(color1: UIColor.clear,
                                               intensity1: 0.05,
                                               color2: UIColor.clear,
                                               intensity2: 0.95))
        return LinearGradient(
            gradient: Gradient(colors: [
                ThemeColor.SemanticColor.layer2.color,
                blendedColor]),
            startPoint: .bottom, endPoint: .top)
    }

    public init(searchText: String = "", focusedOnAppear: Bool = false, enabled: Bool = true, onEditingChanged: ((Bool) -> Void)? = nil, onTextChanged: ((String) -> Void)? = nil) {
        self.searchText = searchText
        self.enabled = enabled
        self.focusedOnAppear = focusedOnAppear
        self.onEditingChanged = onEditingChanged
        self.onTextChanged = onTextChanged
    }

    @Published public var searchText: String = ""
    @Published public var focusedOnAppear: Bool = false
    @Published public var enabled: Bool = true
    @Published public var onEditingChanged: ((Bool) -> Void)?
    @Published public var onTextChanged: ((String) -> Void)?

    private lazy var searchTextBinding = Binding(
        get: {
            self.searchText
        },
        set: {
            self.searchText = $0
            self.onTextChanged?($0)
        }
    )

    public static var previewValue: SearchBoxModel {
        let vm = SearchBoxModel()
        vm.searchText = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = HStack(alignment: .center, spacing: 0) {
                PlatformIconViewModel(type: .asset(name: "icon_search", bundle: Bundle.dydxView),
                                      size: CGSize(width: 16, height: 16),
                                      templateColor: .textTertiary)
                .createView(parentStyle: style)
                .padding(.leading, 16)

                if self.enabled {
                    PlatformInputModel(value: self.searchTextBinding,
                                       currentValue: self.searchText,
                                       placeHolder: DataLocalizer.localize(path: "APP.GENERAL.SEARCH") + "...",
                                       keyboardType: .default,
                                       onEditingChanged: { [weak self] focused in
                        self?.onEditingChanged?(focused)
                    },
                                       focusedOnAppear: self.focusedOnAppear)
                    .createView(parentStyle: style)
                    .frame(height: 40)
                    .padding(.vertical, 2)
                } else {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.SEARCH") + "...")
                        .themeColor(foreground: .textTertiary)
                        .frame(height: 40)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 16)
                        .leftAligned()
                        .frame(maxWidth: .infinity)
                }

                if self.searchText.isNotEmpty {
                    let closeIcon = PlatformIconViewModel(type: .asset(name: "icon_cancel", bundle: Bundle.dydxView),
                                                          clip: .circle(background: .layer3, spacing: 0, borderColor: .layer6),
                                                          size: CGSize(width: 16, height: 16),
                                                          templateColor: .textTertiary)
                    PlatformButtonViewModel(content: closeIcon,
                                            type: .iconType,
                                            action: { [weak self] in
                        self?.searchText = ""
                        self?.onTextChanged?("")
                    })
                    .createView(parentStyle: style)
                    .padding(.trailing, 16)
                }
            }
                .themeColor(background: .layer5)
                .clipShape(Capsule())
                .padding(.vertical, 8)
                .padding(.horizontal, 16)

            return AnyView(view)
        }
    }
}

#if DEBUG
struct SearchBox_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SearchBoxModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SearchBox_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SearchBoxModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
