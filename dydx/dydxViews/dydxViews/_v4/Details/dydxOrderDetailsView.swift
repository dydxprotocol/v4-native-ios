//
//  dydxOrderDetailsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/10/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxOrderDetailsViewModel: PlatformViewModel {
    public struct Item: Equatable {
        public init(title: String? = nil, value: dydxOrderDetailsViewModel.Item.ItemValue? = nil) {
            self.title = title
            self.value = value
        }

        public enum ItemValue: Equatable {
            public static func == (lhs: dydxOrderDetailsViewModel.Item.ItemValue, rhs: dydxOrderDetailsViewModel.Item.ItemValue) -> Bool {
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

    @Published public var side: SideTextViewModel?
    @Published public var logoUrl: URL?
    @Published public var items: [Item] = []
    @Published public var cancelAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxOrderDetailsViewModel {
        let vm = dydxOrderDetailsViewModel()
        vm.side = .previewValue
        vm.logoUrl = URL(string: "https://media.dydx.exchange/currencies/eth.png")
        vm.items = [
            Item(title: "Price", value: .number("12.00")),
            Item(title: "Type", value: .string("Market")),
            Item(title: "Reduce Only", value: .checkmark)
        ]
        vm.cancelAction = {}
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

                    self.createButton(parentStyle: style)
                        .padding(.bottom, 32)

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

            self.side?.createView(parentStyle: parentStyle)

            Spacer()
        }
    }

    private func createButton(parentStyle: ThemeStyle) -> some View {
        Group {
            if let cancelAction = self.cancelAction {
                let content = AnyView(
                    HStack {
                        Spacer()
                        Text(DataLocalizer.localize(path: "APP.TRADE.CANCEL_ORDER"))
                        Spacer()
                    }
                )
                PlatformButtonViewModel(content: content.wrappedViewModel, state: .destructive) {
                    cancelAction()
                }
                .createView(parentStyle: parentStyle)
                .padding(.vertical, 16)
            }
        }
    }
}

#if DEBUG
struct dydxOrderDetailsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxOrderDetailsViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}

struct dydxOrderDetailsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxOrderDetailsViewModel.previewValue
            .createView()
            .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.device)
    }
}
#endif
