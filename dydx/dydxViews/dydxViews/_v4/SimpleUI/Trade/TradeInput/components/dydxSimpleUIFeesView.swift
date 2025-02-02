//
//  dydxSimpleUIFeesView.swift
//  dydxUI
//
//  Created by Rui Huang on 19/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIFeesViewModel: PlatformViewModel {
    @Published public var totalFees: String?
    @Published public var feesPercentage: String?
    @Published public var fees: String?
    @Published public var slippage: String?

    @Published private var present: Bool = false
    private lazy var presentBinding = Binding(
        get: { [weak self] in
            self?.present ?? false
        },
        set: { [weak self] in
            self?.present = $0
        }
    )

    public init() { }

    public static var previewValue: dydxSimpleUIFeesViewModel {
        let vm = dydxSimpleUIFeesViewModel()
        vm.totalFees = "$12.00"
        vm.feesPercentage = "1.2%"
        vm.fees = "$12.00"
        vm.slippage = "$12.00"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self, let totalFees = self.totalFees else { return AnyView(PlatformView.nilView) }

            let feesText = HStack {
                Text(totalFees)
                    .themeColor(foreground: .textSecondary)
                if let feesPercentage = self.feesPercentage {
                    let feesText = "(\(feesPercentage))"
                    Text(feesText)
                }
            }
                .themeFont(fontSize: .small)
                .themeColor(foreground: .textTertiary)

            let iconName: String
            if self.present {
                iconName = "chevron.up"
            } else {
                iconName = "chevron.down"
            }

            let view = Button(action: {  [weak self] in
                    if !(self?.present ?? false) {
                        self?.present = true
                    }
                 }, label: {
                     HStack(alignment: .center) {
                         feesText
                         PlatformIconViewModel(type: .system(name: iconName),
                                               size: CGSize(width: 12, height: 12),
                                               templateColor: .textTertiary)
                             .createView(parentStyle: style)
                     }
                     .padding(.horizontal, 8)
                     .padding(.vertical, 4)
                })
                .popover(present: self.presentBinding, attributes: { attrs in
                    attrs.position = .absolute(
                               originAnchor: .top,
                               popoverAnchor: .bottom
                           )
                    attrs.sourceFrameInset = .init(top: -8, left: 0, bottom: 0, right: 0)
                    attrs.presentation.animation = .none
                    attrs.blocksBackgroundTouches = true
                    attrs.onTapOutside = {
                        self.present = false
                    }
                }, view: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DataLocalizer.localize(path: "APP.GENERAL.ESTIMATED_COST"))
                            .themeFont(fontSize: .small)
                            .themeColor(foreground: .textSecondary)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(self.fees ?? "-")
                                Spacer()
                                Text(DataLocalizer.localize(path: "APP.TRADE.FEE"))
                            }
                            HStack {
                                Text(self.slippage ?? "-")
                                Spacer()
                                Text(DataLocalizer.localize(path: "APP.DEPOSIT_MODAL.SLIPPAGE"))
                            }

                            DividerModel().createView(parentStyle: style)

                            feesText
                        }
                        .themeFont(fontSize: .small)
                        .themeColor(foreground: .textTertiary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: 160)
                    .themeColor(background: .layer3)
                    .cornerRadius(16, corners: .allCorners)
                    .environmentObject(ThemeSettings.shared)
                }, background: {
                    ThemeColor.SemanticColor.layer0.color.opacity(0.7)
                })

            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUIFeesView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIFeesViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIFeesView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIFeesViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
