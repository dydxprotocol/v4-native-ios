//
//  dydxPortfolioSelectorView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/23/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import Popovers

public class dydxPortfolioSelectorViewModel: PlatformViewModel {
    public struct Item: Hashable, Equatable {
        public init(title: String? = nil, subtitle: String? = nil, action: (() -> Void)? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.action = action
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(subtitle)
        }

        public static func == (lhs: dydxPortfolioSelectorViewModel.Item, rhs: dydxPortfolioSelectorViewModel.Item) -> Bool {
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle
        }

        let title: String?
        let subtitle: String?
        let action: (() -> Void)?
    }

    @Published public var items: [Item]?
    @Published public var selectedIndex: Int?

    @Published private var present: Bool = false
    private lazy var presentBinding = Binding(
        get: { [weak self] in
            self?.present ?? false
        },
        set: { [weak self] in
            self?.present = $0
        }
    )

    public init() {}

    public static var previewValue: dydxPortfolioSelectorViewModel {
        let vm = dydxPortfolioSelectorViewModel()
        vm.items = [
            .init(title: "Positions", subtitle: "Monitor your exposure & risk "),
            .init(title: "Orders", subtitle: "Track an order through its lifecycle")
        ]
        vm.selectedIndex = 0
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self, let items = self.items else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Button(action: {  [weak self] in
                    if !(self?.present ?? false) {
                        self?.present = true
                    }
                 }, label: {
                    let selectedIndex = self.selectedIndex ?? 0
                    if selectedIndex < items.count {
                        HStack {
                            Text(items[selectedIndex].title ?? "")
                                .themeFont(fontType: .bold, fontSize: .largest)
                                .themeColor(foreground: .textPrimary)
                            PlatformIconViewModel(type: .system(name: self.present ? "chevron.up": "chevron.down"),
                                                  clip: .circle(background: .layer5, spacing: 16, borderColor: ThemeColor.SemanticColor.layer6),
                                                  size: CGSize(width: 28, height: 28),
                                                  templateColor: .textPrimary)
                            .createView(parentStyle: style)
                        }
                    }
                })
                .popover(present: self.presentBinding, attributes: { attrs in
                    attrs.position = .absolute(
                               originAnchor: .bottom,
                               popoverAnchor: .topLeft
                           )
                    attrs.sourceFrameInset = .init(top: 0, left: 0, bottom: -16, right: 0)
                    attrs.presentation.animation = .none
                    attrs.blocksBackgroundTouches = true
                    attrs.onTapOutside = {
                        self.present = false
                    }
                }, view: {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element) { index, item in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.title ?? "")
                                    .themeFont(fontSize: .medium)
                                    .themeColor(foreground: .textPrimary)
                                    .leftAligned()

                                Text(item.subtitle ?? "")
                                    .themeFont(fontSize: .small)
                                    .themeColor(foreground: .textTertiary)
                                    .leftAligned()
                            }
                            .frame(maxWidth: .infinity)
                            .themeColor(background: .layer3)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .onTapGesture {
                                self.selectedIndex = index
                                item.action?()
                                self.present = false
                            }

                            if index != items.count - 1 {
                                DividerModel().createView(parentStyle: style)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .themeColor(background: .layer3)
                    .cornerRadius(16, corners: .allCorners)
                    .border(cornerRadius: 16)
                    .environmentObject(ThemeSettings.shared)
                }, background: {
                    ThemeColor.SemanticColor.layer0.color.opacity(0.7)
                })

//                Menu(content: {
//                    ForEach(Array(items.enumerated()), id: \.element) { index, item in
//                        Button(action: {
//                            if index != self.selectedIndex {
//                                self.selectedIndex = index
//                                item.action?()
//                            }
//                        }) {
//                            Text(item.title ?? "")
//
//                            Text(item.subtitle ?? "")
//                                .themeFont(fontSize: .smaller)
//                                .themeColor(foreground: .textTertiary)
//                        }
//                        .themeColor(background: .layer6)
//                    }
//                }, label: {
//                    let selectedIndex = self.selectedIndex ?? 0
//                    if selectedIndex < items.count {
//                        HStack {
//                            Text(items[selectedIndex].title ?? "")
//                                .themeFont(fontType: .bold, fontSize: .largest)
//                            PlatformIconViewModel(type: .system(name: "chevron.down"),
//                                                  clip: .circle(background: .layer2, spacing: 16),
//                                                  size: CGSize(width: 28, height: 28),
//                                                  templateColor: .textPrimary)
//                            .createView(parentStyle: style)
//                        }
//                    }
//                })
            )
        }
    }
}

#if DEBUG
struct dydxPortfolioSelectorView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioSelectorViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioSelectorView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioSelectorViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
