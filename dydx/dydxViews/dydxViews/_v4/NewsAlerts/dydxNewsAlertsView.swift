//
//  dydxNewsAlertsView.swift
//  dydxViews
//
//  Created by Rui Huang on 2/7/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxNewsAlertsViewModel: PlatformViewModel {
    @Published public var selectionBar: SelectionBarModel?
    @Published public var blog = PlatformWebViewModel()
    @Published public var alerts: dydxAlertsViewModel?
    @Published public var canGoBack: Bool = false
    @Published public var canGoForward: Bool = false

    public init() {
        super.init()
        blog.pageLoaded = { [weak self] in
            self?.canGoBack = self?.blog.canGoBack ?? false
            self?.canGoForward = self?.blog.canGoForward ?? false
        }
    }

    public static var previewValue: dydxNewsAlertsViewModel {
        let vm = dydxNewsAlertsViewModel()
        vm.selectionBar = .previewValue
        vm.blog = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                if let selectionBar = self.selectionBar {
                    selectionBar.createView(parentStyle: style)
                        .animation(.default, value: self.selectionBar?.items)

                    VStack {
                        // alerts selected
                        if self.selectionBar?.currentSelectionIndex == 0 {
                            self.createAlertsView(parentStyle: style)
                        // news selected
                        } else if self.selectionBar?.currentSelectionIndex == 1 {
                            self.blog.createView(parentStyle: style)
                                .frame(maxHeight: .infinity)
                        }

                        Spacer()
                    }
                } else {
                    self.createHeader(parentStyle: style)
                        .frame(height: 48)
                        .padding([.leading, .trailing])

                    self.createAlertsView(parentStyle: style)
                }
            }
                .themeColor(background: .layer2)

            // make it visible under the tabbar for dark mode only (since the news site is dark only)
            if currentThemeType == .light {
                return AnyView(view)
            } else {
                return AnyView(view.ignoresSafeArea(edges: [.bottom]))
            }
        }
    }

    private func createAlertsView(parentStyle: ThemeStyle) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                self.alerts?.createView(parentStyle: parentStyle)
                    .padding(.horizontal, 8)
                Spacer(minLength: 80)
            }
        }
    }

    private func createHeader(parentStyle: ThemeStyle) -> some View {
        HStack {
            Text(DataLocalizer.localize(path: "APP.GENERAL.ALERTS", params: nil))
                .themeFont(fontType: .bold, fontSize: .largest)

            Spacer()

//            if selectionBar?.currentSelectionIndex == 1 {
//                let iconBack = self.createIcon(imageName: "chevron.compact.left", isEnabled: self.canGoBack)
//                PlatformButtonViewModel(content: iconBack,
//                                        type: .iconType,
//                                        state: self.canGoBack ? .secondary: .disabled,
//                                        action: { [weak self] in self?.blog.goBack() })
//                .createView(parentStyle: parentStyle)
//                .animation(.default)
//
//                let iconForward = self.createIcon(imageName: "chevron.compact.right", isEnabled: self.canGoForward)
//                PlatformButtonViewModel(content: iconForward,
//                                        type: .iconType,
//                                        state: self.canGoForward ? .secondary: .disabled,
//                                        action: { [weak self] in self?.blog.goForward() })
//                .createView(parentStyle: parentStyle)
//                .animation(.default)
//            }
        }
    }

    private func createIcon(imageName: String, isEnabled: Bool) -> PlatformIconViewModel {
        if isEnabled {
            return PlatformIconViewModel(type: .system(name: imageName),
                                         clip: .circle(background: .layer3, spacing: 24, borderColor: .layer6),
                                         size: CGSize(width: 42, height: 42))
        } else {
            return PlatformIconViewModel(type: .system(name: imageName),
                                         clip: .circle(background: .layer1, spacing: 24, borderColor: .layer6),
                                         size: CGSize(width: 42, height: 42), templateColor: .textTertiary)
        }
    }
}

#if DEBUG
struct dydxNewsAlertsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxNewsAlertsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxNewsAlertsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxNewsAlertsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
