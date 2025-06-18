//
//  dydxFundingDetailsView.swift
//  dydxUI
//
//  Created by Rui Huang on 17/06/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxFundingDetailsViewModel: PlatformViewModel {
    public struct Item: Equatable {
        public init(title: String? = nil, value: Item.ItemValue? = nil) {
            self.title = title
            self.value = value
        }

        public enum ItemValue: Equatable {
            public static func == (lhs: Item.ItemValue, rhs: Item.ItemValue) -> Bool {
                false
            }

            case number(String?)
            case string(String?)
            case checkmark
            case any(PlatformViewModel?)
        }
        public var title: String?
        public var value: ItemValue?
    }

    @Published public var status: FundingStatus?
    @Published public var logoUrl: URL?
    @Published public var items: [Item] = []

    public init() { }

    public static var previewValue: dydxFundingDetailsViewModel {
        let vm = dydxFundingDetailsViewModel()
        vm.status = FundingStatus.earned
        vm.logoUrl = URL(string: "https://media.dydx.exchange/currencies/eth.png")
        vm.items = [
            Item(title: "Price", value: .number("12.00")),
            Item(title: "Type", value: .string("Market")),
            Item(title: "Reduce Only", value: .checkmark)
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    self.createHeader(parentStyle: style)
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                    ForEach(self.items, id: \.title) { item in

                        HStack {
                            Text(item.title ?? "")
                                .themeFont(fontSize: .small)
                                .themeColor(foreground: .textTertiary)

                            Spacer()

                            switch item.value {
                            case .checkmark:
                                AnyView(
                                    PlatformIconViewModel(type: .asset(name: "icon_checked", bundle: Bundle.dydxView), size: CGSize(width: 16, height: 16))
                                        .createView(parentStyle: style)
                                )

                            case .number(let text):
                                AnyView(
                                    Text(text ?? "-")
                                        .themeFont(fontType: .number, fontSize: .small)
                                )

                            case .string(let text):
                                AnyView(
                                    Text(text ?? "-")
                                        .themeFont(fontSize: .small)
                                )

                            case .any(let viewModel):
                                if let viewModel = viewModel {
                                    AnyView(
                                        viewModel.createView(parentStyle: style.themeFont(fontSize: .small))
                                    )
                                } else {
                                    AnyView(
                                        Text("-")
                                            .themeFont(fontSize: .small)
                                    )
                                }

                            case .none:
                                AnyView(Text("-"))
                            }
                        }

                        if item != self.items.last {
                            DividerModel().createView(parentStyle: style)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .themeColor(background: .layer2)
                .makeSheet()
            )
        }
    }

    private func createHeader(parentStyle: ThemeStyle) -> some View {
        HStack {
            PlatformIconViewModel(type: .url(url: self.logoUrl),
                                  clip: .defaultCircle,
                                  size: CGSize(width: 40, height: 40),
                                  backgroundColor: .colorWhite)
                .createView(parentStyle: parentStyle)

            Text(status?.directionText ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .large)

            Spacer()
        }
    }

}

#if DEBUG
struct dydxFundingDetailsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxFundingDetailsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxFundingDetailsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxFundingDetailsViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
