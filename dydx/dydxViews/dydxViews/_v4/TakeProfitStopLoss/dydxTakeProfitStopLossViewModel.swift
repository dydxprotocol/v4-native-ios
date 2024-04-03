//
//  dydxTakeProfitStopLossViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 4/1/24.
//

import PlatformUI
import SwiftUI
import Utilities
import Introspect
import dydxFormatter
import Popovers

public class dydxTakeProfitStopLossViewModel: PlatformViewModel {

    @Published public var entryPrice: Double?
    @Published public var oraclePrice: Double?
    @Published public var takeProfitStopLossInputAreaViewModel: dydxTakeProfitStopLossInputAreaModel?

    public init() {}

    public static var previewValue: dydxTakeProfitStopLossViewModel {
        let vm = dydxTakeProfitStopLossViewModel()
        return vm
    }

    private func createHeader() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(localizerPathKey: "APP.TRIGGERS_MODAL.PRICE_TRIGGERS")
                .themeFont(fontType: .plus, fontSize: .larger)
                .themeColor(foreground: .textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(localizerPathKey: "APP.TRIGGERS_MODAL.PRICE_TRIGGERS_DESCRIPTION")
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }

    private func createReceipt() -> some View {
        VStack(spacing: 12) {
            createReceiptLine(titleLocalizerPathKey: "APP.TRIGGERS_MODAL.AVG_ENTRY_PRICE", dollarValue: entryPrice)
            createReceiptLine(titleLocalizerPathKey: "APP.TRADE.ORACLE_PRICE", dollarValue: oraclePrice)
        }
        .padding(.all, 12)
        .themeColor(background: .layer2)
        .clipShape(.rect(cornerRadius: 8))
    }

    private func createReceiptLine(titleLocalizerPathKey: String, dollarValue: Double?) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(localizerPathKey: titleLocalizerPathKey)
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textTertiary)
            Spacer()
            Text(dydxFormatter.shared.dollar(number: dollarValue, digits: 2) ?? "")
                .themeFont(fontType: .number, fontSize: .small)
                .themeColor(foreground: .textPrimary)
        }
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 18) {
                self.createHeader()
                self.createReceipt()
                self.takeProfitStopLossInputAreaViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)

                HStack(alignment: .center, spacing: 8) {
                    Text(localizerPathKey: "APP.GENERAL.ADVANCED")
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontType: .base, fontSize: .small)
                    Rectangle()
                        .frame(height: 1)
                        .themeColor(background: .layer6)
                }
                Spacer()
            }
            .padding(.top, 32)
            .padding([.leading, .trailing])
            .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
            .themeColor(background: .layer3)
            .makeSheet(sheetStyle: .fitSize)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#Preview {
    dydxTakeProfitStopLossViewModel.previewValue
        .createView()
        .previewLayout(.fixed(width: 375, height: 667))
        .previewDisplayName("dydxTakeProfitStopLossViewModel")
}
