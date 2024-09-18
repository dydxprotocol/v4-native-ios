//
//  dydxAlertsView.swift
//  dydxUI
//
//  Created by Rui Huang on 5/3/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAlertsViewModel: PlatformViewModel {
    @Published public var listViewModel: PlatformListViewModel
    @Published public var backAction: (() -> Void)?
    
    public init() {
        self.listViewModel = .init()
    }

    public static var previewValue: dydxAlertsViewModel {
        let vm = dydxAlertsViewModel()
        vm.listViewModel = .init(items: [
            dydxAlertItemModel.previewValue,
            dydxAlertItemModel.previewValue
        ])
        return vm
    }

    private func createAlertsView(parentStyle: ThemeStyle) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                self.listViewModel.createView(parentStyle: parentStyle)
                    .padding(.horizontal, 8)
                Spacer(minLength: 80)
            }
        }
    }

    private func createHeader(parentStyle: ThemeStyle) -> some View {
        HStack(spacing: 16) {
            let buttonContent = PlatformIconViewModel(type: .system(name: "chevron.left"), size: CGSize(width: 16, height: 16), templateColor: .textTertiary)
                PlatformButtonViewModel(content: buttonContent, type: .iconType) {[weak self] in
                    self?.backAction?()
                }
                .createView()
                .padding([.leading, .vertical], 8)
            Text(DataLocalizer.localize(path: "APP.GENERAL.ALERTS", params: nil))
                .themeFont(fontType: .base, fontSize: .largest)
                .themeColor(foreground: .textPrimary)
            Spacer()
        }
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            
            return VStack {
                self.createHeader(parentStyle: style)
                    .frame(height: 48)
                    .padding([.leading, .trailing])

                self.createAlertsView(parentStyle: style)
            }
                .themeColor(background: .layer2)
                .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxAlertsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAlertsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAlertsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAlertsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
