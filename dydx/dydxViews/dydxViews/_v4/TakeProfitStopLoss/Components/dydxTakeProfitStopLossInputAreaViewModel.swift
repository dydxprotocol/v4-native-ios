//
//  dydxTakeProfitStopLossInputAreaViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/3/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTakeProfitStopLossInputAreaModel: PlatformViewModel {
    @Published public var gainInputViewModel: dydxGainLossInputViewModel?
    @Published public var lossInputViewModel: dydxGainLossInputViewModel?
    @Published public var takeProfitPriceInputViewModel: dydxTriggerPriceInputViewModel?
    @Published public var stopLossPriceInputViewModel: dydxTriggerPriceInputViewModel?

    @Published private var isTakeProfitTooltipPresented: Bool = false
    private lazy var isTakeProfitTooltipPresentedBinding = Binding(
        get: { [weak self] in self?.isTakeProfitTooltipPresented == true },
        set: { [weak self] in self?.isTakeProfitTooltipPresented = $0 }
    )

    @Published private var isStopLossTooltipPresented: Bool = false
    private lazy var isStopLossTooltipPresentedBinding = Binding(
        get: { [weak self] in self?.isStopLossTooltipPresented == true },
        set: { [weak self] in self?.isStopLossTooltipPresented = $0 }
    )

    public static var previewValue: dydxTakeProfitStopLossInputAreaModel = {
        let vm = dydxTakeProfitStopLossInputAreaModel()
        vm.gainInputViewModel = dydxGainLossInputViewModel(triggerType: .takeProfit)
        vm.lossInputViewModel = dydxGainLossInputViewModel(triggerType: .stopLoss)
        vm.takeProfitPriceInputViewModel = dydxTriggerPriceInputViewModel(triggerType: .takeProfit)
        vm.stopLossPriceInputViewModel = dydxTriggerPriceInputViewModel(triggerType: .stopLoss)
        return vm
    }()

    private func createTooltipSectionHeader(triggerType: dydxTakeProfitStopLossInputAreaModel.TriggerType) -> some View {
        guard let localizedString = DataLocalizer.shared?.localize(path: triggerType.sectionTitleLocalizerPath, params: nil) else { return EmptyView().wrappedInAnyView() }
        let attributedTitle = AttributedString(localizedString)
            .themeFont(fontSize: .medium)
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

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    self.createTooltipSectionHeader(triggerType: .takeProfit)
                    HStack(spacing: 12) {
                        self.takeProfitPriceInputViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                        self.gainInputViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                    }
                }
                VStack(alignment: .leading, spacing: 16) {
                    self.createTooltipSectionHeader(triggerType: .stopLoss)
                    HStack(spacing: 12) {
                        self.stopLossPriceInputViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                        self.lossInputViewModel?.createView(parentStyle: parentStyle, styleKey: styleKey)
                    }
                }
            }
            .wrappedInAnyView()
        }
    }
}

extension dydxTakeProfitStopLossInputAreaModel {
    public enum TriggerType {
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

#if DEBUG
struct dydxTakeProfitStopLossInputArea_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxTakeProfitStopLossInputAreaModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
