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

private class Input: ObservableObject {
    @Published var value: String = ""
    @Published var placeholder: String = "test"
}

public class dydxTakeProfitStopLossViewModel: PlatformViewModel {

    @Published public var entryPrice: Double?
    @Published public var oraclePrice: Double?

    @Published private var isTakeProfitTooltipPresented: Bool = false
    private lazy var isTakeProfitTooltipPresentedBinding = Binding(
        get: { [weak self] in self?.isTakeProfitTooltipPresented == true },
        set: { [weak self] in self?.isTakeProfitTooltipPresented = $0 }
    )

    @ObservedObject private var takeProfitInput = Input()
    @ObservedObject private var stopLossInput = Input()

    @Published private var isStopLossTooltipPresented: Bool = false
    private lazy var isStopLossTooltipPresentedBinding = Binding(
        get: { [weak self] in self?.isStopLossTooltipPresented == true },
        set: { [weak self] in self?.isStopLossTooltipPresented = $0 }
    )

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

    private func createTooltipSectionHeader(triggerType: TriggerType) -> some View {
        guard let localizedString = DataLocalizer.shared?.localize(path: triggerType.sectionTitleLocalizerPath, params: nil) else { return EmptyView().wrappedInAnyView() }
        let attributedTitle = AttributedString(localizedString)
            .themeFont(fontSize: .small)
            .themeColor(foreground: .textSecondary)

        let binding: Binding<Bool>
        switch triggerType {
        case .takeProfit:
            binding = self.isTakeProfitTooltipPresentedBinding
        case .stopLoss:
            binding = self.isStopLossTooltipPresentedBinding
        }

        return Text(attributedTitle.dottedUnderline(foreground: .textSecondary))
            .onTapGesture { [weak self] in
                switch triggerType {
                case .takeProfit:
                    self?.isTakeProfitTooltipPresented.toggle()
                case .stopLoss:
                    self?.isStopLossTooltipPresented.toggle()
                }
            }
            .popover(present: binding, attributes: {
                $0.position = .absolute(
                      originAnchor: .top,
                      popoverAnchor: .bottom
                  )
                $0.sourceFrameInset = .init(top: 0, left: 0, bottom: -16, right: 0)
                $0.presentation.animation = .none
                $0.blocksBackgroundTouches = true
                $0.onTapOutside = {
                    switch triggerType {
                    case .takeProfit:
                        self.isTakeProfitTooltipPresented = false
                    case .stopLoss:
                        self.isStopLossTooltipPresented = false
                    }
                }
            }, view: {
                Text(localizerPathKey: triggerType.sectionTitleTooltipLocalizerPath)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .textSecondary)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .cornerRadius(8), borderColor: .layer6, lineWidth: 1)
                    .environmentObject(ThemeSettings.shared)
            })
            .wrappedInAnyView()
    }

    private func createTriggerInputArea(triggerType: TriggerType) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            self.createTooltipSectionHeader(triggerType: triggerType)
            HStack(spacing: 12) {
                createPriceInput(triggerType: triggerType, symbol: "usdzs")
                createGainLossValueInput(triggerType: triggerType)
            }
        }
    }

    private func createPriceInput(triggerType: TriggerType, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(localizerPathKey: triggerType.priceInputTitleLocalizerPath)
                    .themeColor(foreground: .textSecondary)
                    .themeFont(fontType: .base, fontSize: .small)
                Text(symbol)
                    .themeColor(foreground: .textSecondary)
                    .themeFont(fontType: .base, fontSize: .small)
                    .padding(.vertical, 1)
                    .padding(.horizontal, 4)
                    .themeColor(background: .layer7)
                    .cornerRadius(4)
            }
            let prompt = Text(dydxFormatter.shared.dollar(number: 0.0, digits: 0) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .number, fontSize: .medium)
            TextField("", text: triggerType == .takeProfit ? $takeProfitInput.value : $stopLossInput.value, prompt: prompt)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .number, fontSize: .medium)

        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .themeColor(background: .layer6)
        .borderAndClip(style: .cornerRadius(8), borderColor: .layer7, lineWidth: 1)
    }

    private func createGainLossValueInput(triggerType: TriggerType) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(localizerPathKey: triggerType.gainLossInputTitleLocalizerPath)
                    .themeColor(foreground: .textSecondary)
                    .themeFont(fontType: .base, fontSize: .small)
            }
            let prompt = Text(dydxFormatter.shared.dollar(number: 0.0, digits: 0) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .number, fontSize: .medium)
            TextField("", text: triggerType == .takeProfit ? $takeProfitInput.value : $stopLossInput.value, prompt: prompt)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .number, fontSize: .medium)

        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .themeColor(background: .layer6)
        .borderAndClip(style: .cornerRadius(8), borderColor: .layer7, lineWidth: 1)
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 18) {
                self.createHeader()
                self.createReceipt()
                self.createTriggerInputArea(triggerType: .takeProfit)
                self.createTriggerInputArea(triggerType: .stopLoss)
                HStack(alignment: .center, spacing: 8) {
                    Text(localizerPathKey: "APP.GENERAL.ADVANCED")
                    Rectangle()
                        .frame(height: 1)
                        .themeFont(fontType: .base, fontSize: .smallest)
                        .themeColor(background: .textTertiary)
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

private extension dydxTakeProfitStopLossViewModel {
    private enum TriggerType {
        case takeProfit
        case stopLoss

        var sectionTitleLocalizerPath: String {
            switch self {
            case .takeProfit:
                return "TRADE.BRACKET_ORDER_SL.TITLE"
            case .stopLoss:
                return "TRADE.BRACKET_ORDER_TP.TITLE"
            }
        }

        var sectionTitleTooltipLocalizerPath: String {
            switch self {
            case .takeProfit:
                return "TRADE.BRACKET_ORDER_SL.BODY"
            case .stopLoss:
                return "TRADE.BRACKET_ORDER_TP.BODY"
            }
        }

        var priceInputTitleLocalizerPath: String {
            switch self {
            case .takeProfit:
                return "APP.TRIGGERS_MODAL.TP_PRICE"
            case .stopLoss:
                return "APP.TRIGGERS_MODAL.SL_PRICE"
            }
        }

        var gainLossInputTitleLocalizerPath: String {
            switch self {
            case .takeProfit:
                return "APP.GENERAL.GAIN"
            case .stopLoss:
                return "APP.GENERAL.LOSS"
            }
        }
    }
}
