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
import KeyboardObserving

public class dydxTakeProfitStopLossViewModel: PlatformViewModel {

    public enum SubmissionStatus {
        case readyToSubmit(cta: String?)
        case needsInput(cta: String?)
        case fixErrors(cta: String?)
        case submitting
    }

    @Published public var submissionReadiness: SubmissionStatus = .needsInput(cta: DataLocalizer.shared?.localize(path: "APP.TRADE.ADD_TRIGGERS", params: nil) ?? "")

    @Published public var submissionAction: (() -> Void)?

    @Published public var entryPrice: String?
    @Published public var oraclePrice: String?
    @Published public var takeProfitStopLossInputAreaViewModel: dydxTakeProfitStopLossInputAreaModel?
    @Published public var customAmountViewModel: dydxCustomAmountViewModel?
    @Published public var customLimitPriceViewModel: dydxCustomLimitPriceViewModel?
    @Published public var shouldDisplayCustomLimitPriceViewModel: Bool = false

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
            createReceiptLine(titleLocalizerPathKey: "APP.TRIGGERS_MODAL.AVG_ENTRY_PRICE", displayText: entryPrice)
            createReceiptLine(titleLocalizerPathKey: "APP.TRADE.ORACLE_PRICE", displayText: oraclePrice)
        }
        .padding(.all, 12)
        .themeColor(background: .layer2)
        .clipShape(.rect(cornerRadius: 8))
    }

    private func createReceiptLine(titleLocalizerPathKey: String, displayText: String?) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(localizerPathKey: titleLocalizerPathKey)
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textTertiary)
            Spacer()
            Text(displayText ?? "")
                .themeFont(fontType: .number, fontSize: .small)
                .themeColor(foreground: .textPrimary)
        }
    }

    private var spinner: AnyView {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(ThemeColor.SemanticColor.textSecondary.color)
            .wrappedInAnyView()
    }

    private func createCta(parentStyle: ThemeStyle, styleKey: String?) -> AnyView? {
        let buttonText: String
        let buttonState: PlatformButtonState
        let spinner: AnyView?

        switch submissionReadiness {
        case .readyToSubmit(let cta):
            buttonText = cta ?? ""
            buttonState = .primary
            spinner = nil
        case .needsInput(let cta):
            buttonText = cta ?? ""
            buttonState = .disabled
            spinner = nil
        case .fixErrors(let cta):
            buttonText = cta ?? ""
            buttonState = .disabled
            spinner = nil
        case .submitting:
            buttonText = DataLocalizer.shared?.localize(path: "APP.TRADE.SUBMITTING_ORDER", params: nil) ?? ""
            buttonState = .disabled
            spinner = self.spinner
        }

        let content = HStack(spacing: 8) {
            Spacer()
            Text(buttonText)
            spinner
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

    var separator: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(localizerPathKey: "APP.GENERAL.ADVANCED")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .small)
            Rectangle()
                .frame(height: 1)
                .overlay(ThemeColor.SemanticColor.layer6.color)
        }
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 0) {
                 VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            self.createHeader()
                            self.createReceipt()
                            self.takeProfitStopLossInputAreaViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                            self.separator
                            self.customAmountViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                            if self.shouldDisplayCustomLimitPriceViewModel {
                                self.customLimitPriceViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                            }
                        }
                    }
                    .keyboardObserving()
                    Spacer(minLength: 18)
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
