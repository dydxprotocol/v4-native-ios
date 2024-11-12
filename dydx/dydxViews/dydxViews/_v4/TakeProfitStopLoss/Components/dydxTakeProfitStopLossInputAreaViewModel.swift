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
    @Published public var numOpenTakeProfitOrders: Int?
    @Published public var takeProfitPriceInputViewModel: dydxPriceInputViewModel?
    @Published public var gainInputViewModel: dydxGainLossInputViewModel?
    @Published public var takeProfitAlert: InlineAlertViewModel?

    @Published public var numOpenStopLossOrders: Int?
    @Published public var stopLossPriceInputViewModel: dydxPriceInputViewModel?
    @Published public var lossInputViewModel: dydxGainLossInputViewModel?
    @Published public var stopLossAlert: InlineAlertViewModel?

    @Published public var multipleOrdersExistViewModel: dydxMultipleOrdersExistViewModel?
    private var hasMultipleTakeProfitOrders: Bool { (numOpenTakeProfitOrders ?? 0) > 1 }
    private var hasMultipleStopLossOrders: Bool { (numOpenStopLossOrders ?? 0) > 1 }

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

    @Published public var onClearTakeProfit: (() -> Void)?
    @Published public var onClearStopLoss: (() -> Void)?

    public static var previewValue: dydxTakeProfitStopLossInputAreaModel = {
        let vm = dydxTakeProfitStopLossInputAreaModel()
        vm.gainInputViewModel = dydxGainLossInputViewModel(triggerType: .takeProfit)
        vm.lossInputViewModel = dydxGainLossInputViewModel(triggerType: .stopLoss)
        vm.takeProfitPriceInputViewModel = dydxPriceInputViewModel(title: "TP Price")
        vm.stopLossPriceInputViewModel = dydxPriceInputViewModel(title: "SL Price")
        return vm
    }()

    private func createTooltip(triggerType: dydxTakeProfitStopLossInputAreaModel.TriggerType) -> some View {
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

    private func createClearButton(triggerType: dydxTakeProfitStopLossInputAreaModel.TriggerType) -> AnyView? {
        let hasInput: Bool
        switch triggerType {
        case .takeProfit:
            hasInput = takeProfitPriceInputViewModel?.value?.isNotEmpty ?? false
        case .stopLoss:
            hasInput = stopLossPriceInputViewModel?.value?.isNotEmpty ?? false
        }
        if hasInput {
            return Text(localizerPathKey: "APP.GENERAL.CLEAR")
                .themeFont(fontType: .base, fontSize: .medium)
                .themeColor(foreground: .colorRed)
                .onTapGesture { [weak self] in
                    PlatformView.hideKeyboard()
                    DispatchQueue.main.async { // wait for the keyboard to dismiss
                        switch triggerType {
                        case .takeProfit:
                            self?.onClearTakeProfit?()
                        case .stopLoss:
                            self?.onClearStopLoss?()
                        }
                    }
                }
                .wrappedInAnyView()
        }
        return nil
    }

    private func createSectionHeader(triggerType: dydxTakeProfitStopLossInputAreaModel.TriggerType) -> some View {
        return HStack(spacing: 0) {
            createTooltip(triggerType: triggerType)
            Spacer()
            createClearButton(triggerType: triggerType)
        }
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        self.createSectionHeader(triggerType: .takeProfit)
                        if self.hasMultipleTakeProfitOrders {
                            self.multipleOrdersExistViewModel?.createView(parentStyle: style, styleKey: styleKey)
                        } else {
                            HStack(spacing: 12) {
                                self.takeProfitPriceInputViewModel?.createView(parentStyle: style, styleKey: styleKey)
                                self.gainInputViewModel?.createView(parentStyle: style, styleKey: styleKey)
                            }
                        }
                        self.takeProfitAlert?.createView(parentStyle: style, styleKey: styleKey)
                    }
                    VStack(alignment: .leading, spacing: 16) {
                        self.createSectionHeader(triggerType: .stopLoss)
                        if self.hasMultipleStopLossOrders {
                            self.multipleOrdersExistViewModel?.createView(parentStyle: style, styleKey: styleKey)
                        } else {
                            HStack(spacing: 12) {
                                self.stopLossPriceInputViewModel?.createView(parentStyle: style, styleKey: styleKey)
                                self.lossInputViewModel?.createView(parentStyle: style, styleKey: styleKey)
                            }
                        }
                        self.stopLossAlert?.createView(parentStyle: style, styleKey: styleKey)
                    }
                }
            }
            .wrappedInAnyView()
        }
    }
}

extension dydxTakeProfitStopLossInputAreaModel {
    public enum TriggerType: CaseIterable {
        case takeProfit
        case stopLoss

        var sectionTitleLocalizerPath: String {
            switch self {
            case .takeProfit:
                return "TRADE.BRACKET_ORDER_TP.TITLE"
            case .stopLoss:
                return "TRADE.BRACKET_ORDER_SL.TITLE"
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
