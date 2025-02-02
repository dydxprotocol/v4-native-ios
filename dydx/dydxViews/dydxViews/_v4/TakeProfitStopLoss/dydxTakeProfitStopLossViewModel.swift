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

public class dydxTakeProfitStopLossViewModel: PlatformViewModel {

    public enum SubmissionStatus {
        case readyToSubmit(cta: String?)
        case needsInput(cta: String?)
        case fixErrors(cta: String?)
        case submitting
    }

    @Published public var submissionReadiness: SubmissionStatus = .needsInput(cta: DataLocalizer.shared?.localize(path: "APP.TRADE.ADD_TRIGGERS", params: nil) ?? "")

    @Published public var submissionAction: (() -> Void)?

    @Published public var icon: URL?
    @Published public var assetId: String?
    @Published public var entryPrice: String?
    @Published public var oraclePrice: String?
    @Published public var takeProfitStopLossInputAreaViewModel: dydxTakeProfitStopLossInputAreaModel?
    @Published public var customAmountViewModel: dydxCustomAmountViewModel?
    @Published public var customLimitPriceViewModel: dydxCustomLimitPriceViewModel?
    @Published public var shouldDisplayCustomLimitPriceViewModel: Bool = false
    @Published public var showAdvanced: Bool = true

    public init() {}

    public static var previewValue: dydxTakeProfitStopLossViewModel {
        let vm = dydxTakeProfitStopLossViewModel()
        vm.icon = URL(string: "https://media.dydx.exchange/currencies/eth.png")
        vm.entryPrice = "100"
        vm.oraclePrice = "100"
        vm.takeProfitStopLossInputAreaViewModel = .previewValue
        vm.customAmountViewModel = .previewValue
        vm.customLimitPriceViewModel = .previewValue
        vm.shouldDisplayCustomLimitPriceViewModel = true
        return vm
    }

    private func createHeader(style: ThemeStyle) -> some View {
        HStack(spacing: 12) {
            PlatformIconViewModel(type: .url(url: icon),
                                  clip: .defaultCircle,
                                  size: CGSize(width: 36, height: 36))
            .createView(parentStyle: style)

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
        }
        .frame(maxWidth: .infinity)
    }

    private func createReceipt(style: ThemeStyle) -> some View {
        HStack(spacing: 12) {
            createReceiptLine(title: DataLocalizer.localize(path: "APP.TRIGGERS_MODAL.AVG_ENTRY_PRICE"),
                              displayText: entryPrice,
                              style: style)
                .frame(maxWidth: .infinity)
            createReceiptLine(title: (assetId ?? "") + " " + DataLocalizer.localize(path: "APP.GENERAL.PRICE"),
                              displayText: oraclePrice,
                              style: style)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
    }

    private func createReceiptLine(title: String, displayText: String?, style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                TokenTextViewModel(symbol: "USD", withBorder: true)
                    .createView(parentStyle: style
                    .themeFont(fontType: .base, fontSize: .smallest))
            }
            .leftAligned()

            Text(displayText ?? "")
                .themeFont(fontType: .base, fontSize: .medium)
                .themeColor(foreground: .textPrimary)
                .leftAligned()
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
        }.wrappedViewModel

        let type: PlatformButtonType
        if showAdvanced {
            type = .defaultType()
        } else {
            type = .defaultType(minHeight: 56, cornerRadius: 16)
        }
        if let submissionAction = submissionAction {
            return PlatformButtonViewModel(content: content, type: type, state: buttonState, action: submissionAction)
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
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        self.createHeader(style: style)
                        self.createReceipt(style: style)
                        self.takeProfitStopLossInputAreaViewModel?.createView(parentStyle: style, styleKey: styleKey)
                        if self.showAdvanced {
                            self.separator
                            self.customAmountViewModel?.createView(parentStyle: style, styleKey: styleKey)
                            if self.shouldDisplayCustomLimitPriceViewModel {
                                self.customLimitPriceViewModel?.createView(parentStyle: style, styleKey: styleKey)
                            }
                        }
                    }
                }
                .keyboardObserving()
                Spacer(minLength: 18)
                self.createCta(parentStyle: style, styleKey: styleKey)
            }
            .padding(.top, 32)
            .padding([.leading, .trailing])
            .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
            .themeColor(background: .layer1)
            .onTapGesture {
                PlatformView.hideKeyboard()
            }
            .keyboardAccessory(background: .layer1, parentStyle: style)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }
}

#if DEBUG
struct dydxTakeProfitStopLossViewModell_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTakeProfitStopLossViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTakeProfitStopLossViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTakeProfitStopLossViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
