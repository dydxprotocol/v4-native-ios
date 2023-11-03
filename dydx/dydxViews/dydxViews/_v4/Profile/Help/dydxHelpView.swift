//
//  dydxHelpView.swift
//  dydxUI
//
//  Created by Rui Huang on 10/24/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxHelpViewModel: PlatformViewModel {
    public struct Item: Identifiable {
        public let id = UUID()

        public init(icon: String, title: String, subtitle: String, onTapAction: (() -> Void)? = nil) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.onTapAction = onTapAction
        }

        let icon: String
        let title: String
        let subtitle: String
        let onTapAction: (() -> Void)?
    }

    @Published public var items: [Item] = []

    public init() { }

    public static var previewValue: dydxHelpViewModel {
        let vm = dydxHelpViewModel()
        vm.items = [
            Item(icon: "help_chatbot", title: "title", subtitle: "subtitle"),
            Item(icon: "help_feedback", title: "title", subtitle: "subtitle"),
            Item(icon: "help_discord", title: "title", subtitle: "subtitle")
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 16) {
                Text(DataLocalizer.localize(path: "APP.HEADER.HELP", params: nil))
                    .themeFont(fontType: .bold, fontSize: .largest)
                    .padding(.top, 40)

                VStack {
                    ForEach(self.items, id: \.id) { item in
                        self.createItem(item: item, style: style)
                    }
                }

                Spacer()
            }
                .padding(.horizontal)
                .themeColor(background: .layer3)
                .makeSheet()

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    @ViewBuilder
    private func createItem(item: Item, style: ThemeStyle) -> some View {
        let icon = PlatformIconViewModel(type: .asset(name: item.icon, bundle: Bundle.dydxView),
                                         size: CGSize(width: 24, height: 24),
                                         templateColor: .textSecondary)
        let main = VStack(alignment: .leading) {
            Text(item.title)
                 .themeFont(fontSize: .small)
                .themeColor(foreground: .textPrimary)

            Text(item.subtitle)
                .themeFont(fontSize: .smaller)
                .themeColor(foreground: .textSecondary)
        }
            .leftAligned()
            .wrappedViewModel

        Group {
            PlatformTableViewCellViewModel(logo: icon,
                                           main: main,
                                           trailing: nil)
                .createView(parentStyle: style)
        }
        .frame(width: UIScreen.main.bounds.width - 32, height: 64)
        .themeColor(background: .layer5)
        .cornerRadius(16)
        .onTapGesture {
            item.onTapAction?()
        }
    }
}

#if DEBUG
struct dydxHelpView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxHelpViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxHelpView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxHelpViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
