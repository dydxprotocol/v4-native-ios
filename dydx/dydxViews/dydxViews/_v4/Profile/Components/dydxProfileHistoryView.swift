//
//  dydxProfileHistoryView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/23/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxProfileHistoryViewModel: dydxTitledCardViewModel {
    public class Item: PlatformViewModel, Equatable {
        public static func == (lhs: dydxProfileHistoryViewModel.Item, rhs: dydxProfileHistoryViewModel.Item) -> Bool {
            lhs.action == rhs.action &&
            lhs.side == rhs.side &&
            lhs.type == rhs.type &&
            lhs.amount == rhs.amount
        }

        public enum ActionType: Equatable {
            case fill(SideTextViewModel?, String)
            case string(String)
        }

        public enum TypeUnion: Equatable {
            case token(TokenTextViewModel)
            case string(String)
        }

        public init(action: ActionType? = nil, side: SideTextViewModel? = nil, type: TypeUnion? = nil, amount: String?) {
            self.action = action
            self.side = side
            self.type = type
            self.amount = amount
        }

        public let action: ActionType?
        public let side: SideTextViewModel?
        public let type: TypeUnion?
        public let amount: String?
    }

    @Published public var items: [Item] = []

    public init() {
        super.init(title: DataLocalizer.localize(path: "APP.GENERAL.HISTORY"))
    }

    public static var previewValue: dydxProfileHistoryViewModel {
        let vm = dydxProfileHistoryViewModel()
        return vm
    }

    public override func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        VStack(spacing: 0) {
            GeometryReader { metrics in
                VStack(spacing: 8) {
                    HStack {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.ACTION"))
                            .leftAligned()
                            .frame(width: metrics.size.width / 10 * 3)
                        Text(DataLocalizer.localize(path: "APP.GENERAL.SIDE"))
                            .leftAligned()
                            .frame(width: metrics.size.width / 10 * 2)
                        Text(DataLocalizer.localize(path: "APP.GENERAL.TYPE"))
                            .leftAligned()
                            .frame(width: metrics.size.width / 10 * 2)
                        Text(DataLocalizer.localize(path: "APP.GENERAL.AMOUNT"))
                            .frame(width: metrics.size.width / 10 * 3)
                            .rightAligned()
                    }

                    ForEach(self.items, id: \.id ) { item in
                        HStack {
                            Group {
                                switch item.action {
                                case .fill(let side, let market):
                                    HStack {
                                        side?.createView(parentStyle: parentStyle.themeFont(fontSize: .smaller))
                                        TokenTextViewModel(symbol: market)
                                            .createView(parentStyle: parentStyle.themeFont(fontSize: .smallest))
                                    }
                                case .string(let value):
                                    Text(value)
                                        .themeColor(foreground: .textSecondary)
                                case .none:
                                    Text("-")
                                }
                            }
                                .themeFont(fontSize: .smaller)
                                .leftAligned()
                                .frame(width: metrics.size.width / 10 * 3)

                            item.side?.createView(parentStyle: parentStyle
                                .themeFont(fontSize: .smaller)
                                .themeColor(foreground: .textTertiary))
                                .leftAligned()
                                .frame(width: metrics.size.width / 10 * 2)

                            if let type = item.type {
                                switch type {
                                case .token(let token):
                                    token.createView(parentStyle: parentStyle.themeFont(fontSize: .smallest)
                                        .themeColor(foreground: .textSecondary))
                                        .leftAligned()
                                        .frame(width: metrics.size.width / 10 * 2)
                                case .string(let value):
                                    Text(value)
                                        .themeFont(fontSize: .smaller)
                                        .themeColor(foreground: .textSecondary)
                                        .leftAligned()
                                        .frame(width: metrics.size.width / 10 * 2)
                                }
                            }

                            Text(item.amount ?? "-")
                                .themeFont(fontSize: .smaller)
                                .themeColor(foreground: .textSecondary)
                                .frame(width: metrics.size.width / 10 * 3)
                                .rightAligned()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .themeFont(fontSize: .smaller)
            .themeColor(foreground: .textTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 134)
        .themeColor(background: .layer3)
        .cornerRadius(12, corners: .allCorners)
        .wrappedInAnyView()
    }
}

#if DEBUG
struct dydxProfileHistoryView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxProfileHistoryViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxProfileHistoryView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxProfileHistoryViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
