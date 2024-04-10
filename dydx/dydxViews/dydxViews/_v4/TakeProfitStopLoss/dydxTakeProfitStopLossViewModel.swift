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

    public enum SubmissionStatus {
        case readyToSubmit
        case needsInput
        case fixErrors(cta: String?)
        case submitting
    }

    @Published public var submissionReadiness: SubmissionStatus = .needsInput
    @Published public var submissionAction: (() -> Void)?

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

    private func createCta(parentStyle: ThemeStyle, styleKey: String?) -> AnyView? {
        let buttonText: String
        let buttonState: PlatformButtonState
        switch submissionReadiness {
        case .readyToSubmit:
            buttonText = DataLocalizer.shared?.localize(path: "APP.TRADE.ADD_TRIGGERS", params: nil) ?? ""
            buttonState = .primary
        case .needsInput:
            buttonText = DataLocalizer.shared?.localize(path: "APP.TRADE.ADD_TRIGGERS", params: nil) ?? ""
            buttonState = .disabled
        case .fixErrors(let cta):
            buttonText = cta ?? ""
            buttonState = .disabled
        case .submitting:
            buttonText = DataLocalizer.shared?.localize(path: "APP.TRADE.SUBMITTING_ORDER", params: nil) ?? ""
            buttonState = .primary
        }
        let content = HStack(spacing: 0) {
            Spacer()
            Text(buttonText)
            Spacer()
        }.wrappedInAnyView()

        if let submissionAction = submissionAction {
            return PlatformButtonViewModel(content: PlatformViewModel(bodyBuilder: { _ in
                content
            }), state: buttonState, action: submissionAction)
            .createView(parentStyle: parentStyle, styleKey: styleKey)
            .wrappedInAnyView()
        } else {
            return nil
        }
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 0) {
                VStack(spacing: 18) {
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
                    self.createCta(parentStyle: parentStyle, styleKey: styleKey)
                }
            }
            .padding(.top, 32)
            .padding([.leading, .trailing])
            .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
            .themeColor(background: .layer3)
            .makeSheet(sheetStyle: .fitSize)
            .onTapGesture {
                PlatformView.hideKeyboard()
            }

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
