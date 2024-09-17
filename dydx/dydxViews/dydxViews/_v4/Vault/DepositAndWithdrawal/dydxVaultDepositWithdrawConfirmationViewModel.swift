//
//  dydxVaultDepositWithdrawConfirmationViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 9/6/24.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxVaultDepositWithdrawConfirmationViewModel: PlatformViewModel {
    public enum State {
        case enabled
        case submitting
        case loading
        case disabled
    }

    @Published public var amount: Double?
    @Published public var transferType: VaultTransferType?
    @Published public var faqUrl: String?

    @Published public var submitState: State = .enabled

    @Published public var submitAction: (() -> Void)?
    @Published public var cancelAction: (() -> Void)?
    @Published public var curVaultBalance: Double?
    @Published public var curFreeCollateral: Double?
    @Published public var curMarginUsage: Double?
    @Published public var postVaultBalance: Double?
    @Published public var postFreeCollateral: Double?
    @Published public var postMarginUsage: Double?
    @Published public var slippage: Double?
    public var expectedAmount: Double? {
        guard let slippage = slippage, let amount = amount else { return nil }
        return amount * slippage
    }

    @Published public var requiresAcknowledgeHighSlippage: Bool = false
    @Published public var isFirstSubmission: Bool = true

    @Published fileprivate(set) public var hasAcknowledgedHighSlippage: Bool = false

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return VaultDepositWithdrawConfirmationView(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

private struct VaultDepositWithdrawConfirmationView: View {
    @ObservedObject var viewModel: dydxVaultDepositWithdrawConfirmationViewModel

    var options = VaultTransferType.allCases

    var body: some View {

        VStack(spacing: 24) {
            titleRow
            transferVisualization
            Spacer()
            receipts
            withdrawalSlippageInlineAlert
            checkboxRow
            submitButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 48)
        .padding(.bottom, self.safeAreaInsets?.bottom)
        .makeSheet()
        .frame(maxWidth: .infinity)
        .themeColor(background: .layer3)
        .ignoresSafeArea(edges: [.bottom])
    }

    private var titleRow: some View {
        HStack(spacing: 16) {
            backButton
            titleText
            Spacer()
        }
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    private var titleText: some View {
        if let transferType = viewModel.transferType {
            Text(transferType.confirmTransferText)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .plus, fontSize: .largest)
        }
    }

    private var backButton: some View {
        ChevronBackButtonModel(onBackButtonTap: viewModel.cancelAction ?? {})
            .createView()
    }

    @ViewBuilder
    private var transferVisualization: some View {
        if let transferType = viewModel.transferType {
            HStack(alignment: .center, spacing: 16) {
                generationTransferStep(title: transferType.transferOriginTitleText, thumbnail: transferType.transferOriginImage, subtitle: dydxFormatter.shared.dollar(number: viewModel.amount)  ?? "--")
                Image(systemName: "chevron.forward.dotted.chevron.forward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .themeColor(foreground: .textTertiary)
                generationTransferStep(title: transferType.transferDestinationTitleText, thumbnail: transferType.transferDestinationImage, subtitle: transferType.transferDestinationSubtitleText)
            }
            .fixedSize(horizontal: false, vertical: true)
        }

    }

    private func generationTransferStep(title: String, thumbnail: Image?, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .small)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            VStack(spacing: 8) {
                if let thumbnail {
                    thumbnail
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                } else {
                    let thumbnailText = subtitle.prefix(1)
                    Text(thumbnailText)
                        .frame(width: 32, height: 32)
                        .themeColor(foreground: .textTertiary)
                        .themeColor(background: .layer1)
                        .clipShape(.circle)
                }
                Text(subtitle)
                    .themeColor(foreground: .textSecondary)
                    .themeFont(fontType: .base, fontSize: .medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .centerAligned()
            .padding(.all, 16)
            .themeColor(background: .layer2)
            .clipShape(.rect(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var receipts: some View {
        if let transferType = viewModel.transferType {
            let slippageTitle = DataLocalizer.localize(path: "APP.VAULTS.EST_SLIPPAGE")
            let expectedAmountTitle = DataLocalizer.localize(path: "APP.WITHDRAW_MODAL.EXPECTED_AMOUNT_RECEIVED")

            let preTransferVaultBalance = AmountTextModel(amount: viewModel.curVaultBalance?.asNsNumber)
            let preTransferFreeCollateral = AmountTextModel(amount: viewModel.curFreeCollateral?.asNsNumber)
            let preTransferMarginUsage = AmountTextModel(amount: viewModel.curMarginUsage?.asNsNumber)

            let postTransferVaultBalance = AmountTextModel(amount: viewModel.postVaultBalance?.asNsNumber)
            let postTransferFreeCollateral = AmountTextModel(amount: viewModel.postFreeCollateral?.asNsNumber)
            let postTransferMarginUsage = AmountTextModel(amount: viewModel.postMarginUsage?.asNsNumber)

            let estSlippage = AmountTextModel(amount: viewModel.slippage?.asNsNumber, unit: .percentage)
            let expectedAmount = AmountTextModel(amount: viewModel.expectedAmount?.asNsNumber)

            let vaultBalanceReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.VAULTS.YOUR_VAULT_BALANCE"),
                                                                        value: AmountChangeModel(before: preTransferVaultBalance, after: postTransferVaultBalance))
            let freeCollateralReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.GENERAL.FREE_COLLATERAL"),
                                                                        value: AmountChangeModel(before: preTransferFreeCollateral, after: postTransferFreeCollateral))
            let marginUsageReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.GENERAL.MARGIN_USAGE"),
                                                                        value: AmountChangeModel(before: preTransferMarginUsage, after: postTransferMarginUsage))
            let estSlippageReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.VAULTS.EST_SLIPPAGE"),
                                                                        value: AmountChangeModel(before: estSlippage, after: nil))
            let expectedAmountReceiptItem = dydxReceiptChangeItemView(title: DataLocalizer.localize(path: "APP.WITHDRAW_MODAL.EXPECTED_AMOUNT_RECEIVED"),
                                                                        value: AmountChangeModel(before: expectedAmount, after: nil))

            VStack(spacing: 8) {
                switch transferType {
                case .deposit:
                    freeCollateralReceiptItem.createView()
                    marginUsageReceiptItem.createView()
                    vaultBalanceReceiptItem.createView()
                case .withdraw:
                    freeCollateralReceiptItem.createView()
                    vaultBalanceReceiptItem.createView()
                    if let slippage = viewModel.slippage {
                        estSlippageReceiptItem.createView()
                        expectedAmountReceiptItem.createView()
                    } else {
                        dydxReceiptLoadingItemView(title: slippageTitle).createView()
                        dydxReceiptLoadingItemView(title: expectedAmountTitle).createView()
                    }
                }
            }
            .padding(.all, 16)
            .themeColor(background: .layer2)
            .clipShape(.rect(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var withdrawalSlippageInlineAlert: some View {
        if let faqUrl = viewModel.faqUrl,
            let slippage = viewModel.slippage, viewModel.requiresAcknowledgeHighSlippage {
            let withdrawalSlippageInlineAlertAttributedText = AttributedString(localizerPathKey: "APP.VAULTS.SLIPPAGE_WARNING",
                                                                               params: ["LINK": DataLocalizer.localize(path: "APP.VAULTS.VAULT_FAQS"),
                                                                                        "AMOUNT": dydxFormatter.shared.percent(number: slippage, digits: 2) ?? "--"],
                                                                               hyperlinks: ["APP.VAULTS.VAULT_FAQS": faqUrl],
                                                                               foreground: .textPrimary)
            InlineAlertViewModel(.init(title: nil,
                                       body: withdrawalSlippageInlineAlertAttributedText,
                                       level: .warning))
            .createView()
        }
    }

    @ViewBuilder
    private var checkboxRow: some View {
        if viewModel.requiresAcknowledgeHighSlippage {
            dydxCheckboxView(isChecked: $viewModel.hasAcknowledgedHighSlippage,
                             text: DataLocalizer.localize(path: "APP.VAULTS.SLIPPAGE_ACK",
                                                          params: ["AMOUNT": dydxFormatter.shared.percent(number: viewModel.slippage, digits: 2) ?? "--"]))
            .disabled(viewModel.submitState == .submitting)
        }
    }

    @ViewBuilder
    private var spinner: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(ThemeColor.SemanticColor.textSecondary.color)
    }

    @ViewBuilder
    public var buttonContent: some View {
        if let transferType = viewModel.transferType {
            Group {
                switch viewModel.submitState {
                case .enabled, .loading:
                    Text(viewModel.isFirstSubmission ? transferType.confirmTransferText : DataLocalizer.localize(path: "APP.ONBOARDING.TRY_AGAIN"))
                case .submitting:
                    HStack {
                        Text(DataLocalizer.localize(path: "APP.TRADE.SUBMITTING"))
                        spinner
                    }
                case .disabled:
                    if viewModel.requiresAcknowledgeHighSlippage && !viewModel.hasAcknowledgedHighSlippage {
                        Text(DataLocalizer.localize(path: "APP.VAULTS.ACKNOWLEDGE_HIGH_SLIPPAGE"))
                    } else {
                        Text(transferType.confirmTransferText)
                    }
                }
            }
            .themeFont(fontType: .base, fontSize: .large)
        }
    }

    private var submitButton: some View {
        let state: PlatformButtonState = viewModel.submitState == .enabled ? .primary : .disabled
        return PlatformButtonViewModel(content: buttonContent.wrappedViewModel, state: state, action: viewModel.submitAction ?? {})
            .createView()
    }
}
