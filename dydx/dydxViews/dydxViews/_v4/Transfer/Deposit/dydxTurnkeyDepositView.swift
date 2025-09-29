//
//  dydxTurnkeyDepositView.swift
//
//  Created by Rui Huang on 04/08/2025.
//  Copyright Fambot.  All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTurnkeyDepositViewModel: PlatformViewModel {
    public struct Item: Equatable, Hashable {
        public init(title: String, subtitle: String, tag: String, icon: URL?, action: @escaping () -> Void) {
            self.title = title
            self.subtitle = subtitle
            self.tag = tag
            self.icon = icon
            self.action = action
        }

        public static func == (lhs: dydxTurnkeyDepositViewModel.Item, rhs: dydxTurnkeyDepositViewModel.Item) -> Bool {
            lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.tag == rhs.tag &&
            lhs.icon == rhs.icon
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(subtitle)
            hasher.combine(tag)
        }

        public let title: String
        public let subtitle: String
        public let tag: String
        public let icon: URL?
        public let action: () -> Void
    }

    @Published public var items: [Item] = []
    @Published public var fiatAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxTurnkeyDepositViewModel {
        let vm = dydxTurnkeyDepositViewModel()
        vm.items = [
            .init(title: "Title 1", subtitle: "Subtitle 1", tag: "1", icon: URL(string: "https://v4.testnet.dydx.exchange/chains/ethereum.png")!, action: {})
         ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack {
                Text(DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT"))
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .larger)
                    .centerAligned()
                    .padding(.vertical, 8)
                    .padding(.top, 16)
                    .frame(height: 54)

                DividerModel().createView(parentStyle: style)
                    .padding(.horizontal, -16)

                ForEach(self.items, id: \.self) { item in
                    self.createItemView(item: item, style: style)
                }

                Spacer()

                if let fiatAction = self.fiatAction {
                    self.createDivider(parentStyle: style)
                    dydxFiatDepositItemViewModel(selectAction: fiatAction)
                        .createView(parentStyle: style)
                }
            }
                .padding(.horizontal)
                .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                .themeColor(background: .layer2)
                .ignoresSafeArea(edges: [.bottom])

            return AnyView(view)
        }
    }

    private func createItemView(item: Item, style: ThemeStyle) -> some View {
        HStack(spacing: 12) {
            PlatformIconViewModel(type: .url(url: item.icon), clip: .circle(background: .transparent, spacing: 0), size: CGSize(width: 32, height: 32))
                .createView(parentStyle: style)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .small)

                Text(item.subtitle)
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .smaller)
            }

            Spacer()

            Text(item.tag)
                .themeColor(foreground: .colorPurple)
                .themeFont(fontSize: .smallest)
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .themeColor(background: .colorFadedPurple)
                .cornerRadius(6, corners: .allCorners)

            PlatformIconViewModel(type: .asset(name: "icon_chevron", bundle: Bundle.dydxView),
                                  size: CGSize(width: 12, height: 12),
                                  templateColor: .textTertiary)
            .createView(parentStyle: style)
        }
        .padding(.vertical, 8)
        .themeColor(background: .layer2)
        .onTapGesture {
            item.action()
        }
    }

    private func createDivider(parentStyle: ThemeStyle) -> some View {
        ZStack(alignment: .center) {
            DividerModel().createView(parentStyle: parentStyle)
            Text(DataLocalizer.localize(path: "APP.GENERAL.OR"))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smaller)
                .padding(.horizontal, 8)
                .themeColor(background: .layer2)
        }
    }
}

#if DEBUG
struct dydxTurnkeyDepositView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTurnkeyDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTurnkeyDepositView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTurnkeyDepositViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
