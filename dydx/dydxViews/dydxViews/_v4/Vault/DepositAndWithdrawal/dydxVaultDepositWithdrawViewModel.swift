//
//  dydxVaultDepositWithdrawViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 8/22/24.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxVaultDepositWithdrawViewModel: PlatformViewModel {
    public enum State {
        case enabled
        case disabled
    }

    @Published public var submitState: State = .disabled
    @Published public var submitAction: (() -> Void)?

    @Published public private(set) var numberFormatter = dydxNumberInputFormatter(fractionDigits: 2)

    @Published public var selectedTransferType: VaultTransferType = .deposit
    @Published public fileprivate(set) var amount: Double?
    @Published public var maxAmount: Double = 0

    @Published public var inputReceiptChangeItems: [dydxReceiptChangeItemView]?
    @Published public var inputInlineAlert: InlineAlertViewModel?

    @Published public var curVaultBalance: Double?
    @Published public var curFreeCollateral: Double?
    @Published public var curMarginUsage: Double?

    @Published public var postVaultBalance: Double?
    @Published public var postFreeCollateral: Double?
    @Published public var postMarginUsage: Double?

    @Published public var slippage: Double?
    @Published public var expectedAmountReceived: Double?

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return VaultDepositWithdrawView(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

private struct VaultDepositWithdrawView: View {
    @ObservedObject var viewModel: dydxVaultDepositWithdrawViewModel

    var options = VaultTransferType.allCases

    private var radioButtonSelector: some View {
        RadioButtonGroup(selected: $viewModel.selectedTransferType,
                         options: options,
                         fontType: .plus,
                         fontSize: .larger,
                         itemWidth: nil,
                         itemHeight: 44)
        .leftAligned()
    }

    var body: some View {

        VStack(spacing: 0) {
            radioButtonSelector
            Color.clear.frame(height: 24)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    inputArea
                    viewModel.inputInlineAlert?.createView()
                }
            }
            Spacer(minLength: 18)
            buttonArea
        }
        .padding(.horizontal, 16)
        .padding(.top, 48)
        .padding(.bottom, self.safeAreaInsets?.bottom)
        .makeSheet()
        .frame(maxWidth: .infinity)
        .themeColor(background: .layer3)
        .ignoresSafeArea(edges: [.bottom])
        .onTapGesture {
            PlatformView.hideKeyboard()
        }
    }

    private var inputArea: some View {
        VStack(spacing: 16) {
            dydxTitledNumberField(title: viewModel.selectedTransferType.inputFieldTitle,
                                  accessoryTitle: nil,
                                  numberFormatter: viewModel.numberFormatter,
                                  minValue: 0,
                                  maxValue: viewModel.maxAmount,
                                  isMaxButtonVisible: true,
                                  withBorder: true,
                                  value: $viewModel.amount)
            inputReceipts
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .themeColor(background: .layer2)
        .clipShape(.rect(cornerRadius: 10))
    }

    private var submitButton: some View {
        let content = Text(viewModel.selectedTransferType.previewTransferText)
            .themeColor(foreground: .textPrimary)
            .themeFont(fontType: .base, fontSize: .large)
        let state: PlatformButtonState
        switch viewModel.submitState {
        case .enabled:
            state = .primary
        case .disabled:
            state = .disabled
        }
        return PlatformButtonViewModel(content: content.wrappedViewModel, state: state, action: viewModel.submitAction ?? {})
            .createView()
    }

    private func makeReceiptItem(titleKey: String, preValue: Double?, postValue: Double?, unit: AmountTextModel.Unit = .dollar, isLoading: Bool = false) -> some View {
        if isLoading {
            return dydxReceiptLoadingItemView(title: DataLocalizer.localize(path: titleKey)).createView()
        } else {
            let preAmountText = AmountTextModel(amount: preValue?.asNsNumber, unit: unit)
            let postAmountText = postValue != nil ? AmountTextModel(amount: postValue?.asNsNumber, unit: unit) : nil
            let change = AmountChangeModel(before: preAmountText, after: postAmountText)
            return dydxReceiptChangeItemView(title: DataLocalizer.localize(path: titleKey), value: change).createView()
        }
    }

    @ViewBuilder
    private var inputReceipts: some View {
        switch viewModel.selectedTransferType {
        case .deposit:
            makeReceiptItem(titleKey: "APP.GENERAL.CROSS_FREE_COLLATERAL", preValue: viewModel.curFreeCollateral, postValue: viewModel.postFreeCollateral)
        case .withdraw:
            makeReceiptItem(titleKey: "APP.VAULTS.YOUR_VAULT_BALANCE", preValue: viewModel.curVaultBalance, postValue: viewModel.postVaultBalance)
        }
    }

    @ViewBuilder
    private var receipts: some View {
        VStack(spacing: 8) {
            switch viewModel.selectedTransferType {
            case .deposit:
                makeReceiptItem(titleKey: "APP.GENERAL.MARGIN_USAGE", preValue: viewModel.curMarginUsage, postValue: viewModel.postMarginUsage, unit: .percentage)
                makeReceiptItem(titleKey: "APP.VAULTS.YOUR_VAULT_BALANCE", preValue: viewModel.curVaultBalance, postValue: viewModel.postVaultBalance)
            case .withdraw:
                makeReceiptItem(titleKey: "APP.GENERAL.CROSS_FREE_COLLATERAL", preValue: viewModel.curFreeCollateral, postValue: viewModel.postFreeCollateral)
                makeReceiptItem(titleKey: "APP.VAULTS.EST_SLIPPAGE", preValue: viewModel.slippage, postValue: nil, unit: .percentage)
                makeReceiptItem(titleKey: "APP.WITHDRAW_MODAL.EXPECTED_AMOUNT_RECEIVED", preValue: viewModel.expectedAmountReceived, postValue: nil)
            }
        }
        .padding(.horizontal, 16)
    }

    private var buttonArea: some View {
        VStack(spacing: 16) {
            receipts
            submitButton
        }
        .padding(.top, 16)
        .themeColor(background: .layer2)
        .clipShape(.rect(cornerRadius: 10))
    }
}
