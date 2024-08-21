//
//  dydxTradingNetworkView.swift
//  dydxViews
//
//  Created by Rui Huang on 3/14/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTradingNetworkItemViewModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var selected = false
    @Published public var onSelected: (() -> Void)?

    public init() { }

    public static var previewValue: dydxTradingNetworkItemViewModel {
        let vm = dydxTradingNetworkItemViewModel()
        vm.text = "Test String"
        vm.selected = true
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Group {
                     let status = PlatformIconViewModel(type: .asset(name: "status_filled", bundle: Bundle.dydxView),
                                                        size: CGSize(width: 8, height: 8),
                                                        templateColor: self.selected ? .colorGreen : .textTertiary)
                        .createView(parentStyle: style)

                    let main =
                        Text(self.text ?? "")
                            .lineLimit(1)
                            .themeFont(fontSize: .medium)
                            .themeColor(foreground: .textPrimary)

                    Group {
                        PlatformTableViewCellViewModel(leading: status.wrappedViewModel,
                                                       logo: PlatformView.nilViewModel,
                                                       main: main.wrappedViewModel,
                                                       trailing: PlatformView.nilViewModel)
                            .createView(parentStyle: style)
                    }
                    .frame(width: UIScreen.main.bounds.width - 32, height: 64)
                    .themeColor(background: .layer3)
                    .cornerRadius(16)
                    .onTapGesture { [weak self] in
                        self?.onSelected?()
                    }
                }
            )
        }
    }
}

public class dydxTradingNetworkViewModel: PlatformViewModel {
    @Published public var items: [dydxTradingNetworkItemViewModel] = []

    public init() { }

    public static var previewValue: dydxTradingNetworkViewModel {
        let vm = dydxTradingNetworkViewModel()
        vm.items = [
            dydxTradingNetworkItemViewModel.previewValue,
            dydxTradingNetworkItemViewModel.previewValue
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 16) {
                Text(DataLocalizer.localize(path: "APP.V4.SWITCH_NETWORK", params: nil))
                    .themeFont(fontType: .plus, fontSize: .largest)

                ScrollView(showsIndicators: false) {
                    ForEach(self.items, id: \.id) { item in
                        item.createView(parentStyle: style)
                    }
                }

                Spacer()
            }
                .padding([.leading, .trailing])
                .padding(.top, 40)
                .themeColor(background: .layer2)
                .makeSheet()

            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxTradingNetworkView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradingNetworkViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradingNetworkView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradingNetworkViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
