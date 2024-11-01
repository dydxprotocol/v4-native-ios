//
//  dydxVaultHistoryItemView.swift
//  dydxUI
//
//  Created by Rui Huang on 31/10/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxVaultHistoryItemViewModel: PlatformViewModel {
    @Published public var date: String?
    @Published public var time: String?
    @Published public var action: String?
    @Published public var amount: String?
    @Published public var onTapAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxVaultHistoryItemViewModel {
        let vm = dydxVaultHistoryItemViewModel()
        vm.date = "202-10-31"
        vm.time = "11:11"
        vm.action = "Deposit"
        vm.amount = "$100.00"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text(self.date ?? "")

                        Text(self.time ?? "")
                            .themeColor(foreground: .textTertiary)
                    }
                    .leftAligned()
                    .frame(width: 120)

                    Text(self.action ?? "")
                        .leftAligned()

                    HStack {
                        Text(self.amount ?? "")
                            .rightAligned()
                        PlatformIconViewModel(type: .asset(name: "icon_external_link",
                                                           bundle: .dydxView),
                                              clip: .noClip,
                                              size: .init(width: 16, height: 16),
                                              templateColor: .textSecondary)
                        .createView(parentStyle: parentStyle)
                    }
                        .frame(width: 120)
                }
                    .themeFont(fontSize: .small)
                    .padding(.horizontal, 8)
                    .onTapGesture {
                        self.onTapAction?()
                    }
            )
        }
    }
}

public class dydxVaultHistoryListViewModel: PlatformListViewModel {
    public static var previewValue: dydxVaultHistoryListViewModel {
        let vm = dydxVaultHistoryListViewModel()
        vm.items = [
            dydxVaultHistoryItemViewModel.previewValue,
            dydxVaultHistoryItemViewModel.previewValue,
            dydxVaultHistoryItemViewModel.previewValue
        ]
        return vm
    }

    public init() {
        super.init()
        self.width = UIScreen.main.bounds.width - 16
    }

    public override var header: PlatformViewModel? {
        guard items.count > 0 else { return nil }
        return
            HStack(spacing: 0) {
                Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.TIME", params: nil) ?? "")
                    .leftAligned()
                    .frame(width: 120)
                Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.ACTION", params: nil) ?? "")
                    .leftAligned()
                Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.AMOUNT", params: nil) ?? "")
                    .rightAligned()
                    .frame(width: 120)
            }
        .padding(.horizontal, 8)
        .themeFont(fontSize: .smaller)
        .themeColor(foreground: .textTertiary)
        .wrappedViewModel
    }
}

#if DEBUG
struct dydxVaultHistoryItemView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxVaultHistoryItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxVaultHistoryItemView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxVaultHistoryItemViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
