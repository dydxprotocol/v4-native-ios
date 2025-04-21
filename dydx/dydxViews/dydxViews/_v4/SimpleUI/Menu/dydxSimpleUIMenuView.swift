//
//  dydxSimpleUIMenuView.swift
//  dydxUI
//
//  Created by Rui Huang on 18/04/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMenuViewModel: PlatformViewModel {
    @Published public var account: dydxSimpleUIMenuAccountViewModel?
    @Published public var buttons: dydxSimpleUIMenuButtonsViewModel?

    public struct MenuItem: Hashable, Equatable {
        public init(icon: String, title: String, subtitle: String? = nil, destructive: Bool = false, action: @escaping () -> Void) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.destructive = destructive
            self.action = action
        }

        public var icon: String
        public var title: String
        public var subtitle: String?
        public var destructive: Bool
        public var action: () -> Void

        public func hash(into hasher: inout Hasher) {
            hasher.combine(icon)
            hasher.combine(title)
            hasher.combine(destructive)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.icon == rhs.icon &&
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.destructive == rhs.destructive
        }
    }

    @Published public var items: [MenuItem] = []

    @Published public var onboarded: Bool = false

    @Published public var depositAction: (() -> Void)?
    @Published public var withdrawAction: (() -> Void)?
    @Published public var switchModeAction: (() -> Void)?

    public lazy var toggleBinding = Binding<Bool> {
        return false
    } set: { _ in
        self.switchModeAction?()
    }

    public init() { }

    public static var previewValue: dydxSimpleUIMenuViewModel {
        let vm = dydxSimpleUIMenuViewModel()
        vm.account = .previewValue
        vm.items = [
            .init(icon: "icon_copy", title: "Settings", subtitle: nil, action: {}),
            .init(icon: "icon_copy", title: "Onboarding", subtitle: "subtitle", action: {})
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 24) {
                if self.onboarded {
                    self.account?.createView(parentStyle: style)
                    self.buttons?.createView(parentStyle: style)
                }

                VStack(alignment: .leading, spacing: 0) {
                    self.createSwitchModeItem(parentStyle: style)

                    Divider()
                        .frame(height: 2)
                        .overlay(ThemeColor.SemanticColor.layer2.color)

                    ForEach(Array(self.items.enumerated()), id: \.element) { index, item in
                        self.createMenuItem(item: item, parentStyle: style)
                        if index != self.items.count - 1 {
                            Divider()
                                .frame(height: 2)
                                .overlay(ThemeColor.SemanticColor.layer2.color)
                        }
                    }
                 }
                .themeColor(background: .layer1)
                .cornerRadius(16, corners: .allCorners)

                Spacer()
            }
                .padding([.leading, .trailing])
                .padding(.top, 32)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer2)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private func createSwitchModeItem(parentStyle: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                PlatformIconViewModel(type: .asset(name: "icon_switch", bundle: .dydxView),
                                      size: CGSize(width: 22, height: 22),
                                      templateColor: .textSecondary)
                .createView(parentStyle: parentStyle)

                VStack(alignment: .leading, spacing: 2) {
                    Text(DataLocalizer.localize(path: "APP.TRADE.MODE.SWITCH_TO_PRO"))
                        .themeFont(fontSize: .large)
                        .themeColor(foreground: .textSecondary)

                    Text(DataLocalizer.localize(path: "APP.TRADE.MODE.FULLY_FEATURED"))
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                }

                Spacer()

                Toggle("", isOn: toggleBinding)
                    .tint(ThemeColor.SemanticColor.colorPurple.color)

            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .onTapGesture { [weak self] in
                self?.switchModeAction?()
            }
        }
    }

    private func createMenuItem(item: MenuItem, parentStyle: ThemeStyle) -> some View {
        let color: ThemeColor.SemanticColor
        if item.destructive {
            color = .colorRed
        } else {
            color = .textSecondary
        }
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                PlatformIconViewModel(type: .asset(name: item.icon, bundle: .dydxView),
                                      size: CGSize(width: 22, height: 22),
                                      templateColor: color)
                .createView(parentStyle: parentStyle)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .themeFont(fontSize: .large)
                        .themeColor(foreground: color)

                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textTertiary)
                    }
                }

                Spacer()

                PlatformIconViewModel(type: .asset(name: "icon_chevron", bundle: Bundle.dydxView),
                                      size: CGSize(width: 12, height: 12),
                                      templateColor: .textTertiary)
                    .createView(parentStyle: parentStyle)

            }
            .themeColor(background: .layer1)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .onTapGesture {
                item.action()
            }
        }
    }
}

#if DEBUG
struct dydxSimpleUIMenuView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMenuViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMenuView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMenuViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
