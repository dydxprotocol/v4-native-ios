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
        case disabled
    }

    fileprivate var submitState: State {
        hasAcknowledgedHighSlippage ? .enabled : .disabled
    }

    public var submitAction: (() -> Void)?
    public var cancelAction: (() -> Void)?
    public var elevatedSlippageAmount: Double?
    public var receiptItems: [dydxReceiptChangeItemView]?

    @Published public var transferType: VaultTransferType
    @Published public var requiresAcknowledgeHighSlippage: Bool = false

    @Published fileprivate var amount: Double?
    @Published fileprivate var hasAcknowledgedHighSlippage: Bool = false

    public init(transferType: VaultTransferType) {
        self.transferType = transferType

    }

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

    private var titleText: some View {
        Text(viewModel.transferType.confirmTransferText)
            .themeColor(foreground: .textPrimary)
            .themeFont(fontType: .plus, fontSize: .largest)
    }

    private var backButton: some View {
        ChevronBackButtonModel(onBackButtonTap: viewModel.cancelAction ?? {})
            .createView()
    }

    private var transferVisualization: some View {
        return HStack(alignment: .center, spacing: 16) {
            generationTransferStep(title: viewModel.transferType.transferOriginTitleText, thumbnail: viewModel.transferType.transferOriginImage, subtitle: "placeholder")
            Image(systemName: "chevron.forward.dotted.chevron.forward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .themeColor(foreground: .textTertiary)
            generationTransferStep(title: viewModel.transferType.transferDestinationTitleText, thumbnail: viewModel.transferType.transferDestinationImage, subtitle: viewModel.transferType.transferDestinationSubtitleText)
        }
        .fixedSize(horizontal: false, vertical: true)

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
        if viewModel.receiptItems?.count ?? 0 > 0 {
            VStack(spacing: 8) {
                ForEach(viewModel.receiptItems ?? [], id: \.id) { $0.createView() }
            }
            .padding(.all, 16)
            .themeColor(background: .layer2)
            .clipShape(.rect(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var withdrawalSlippageInlineAlert: some View {
        if let elevatedSlippageAmount = viewModel.elevatedSlippageAmount {
            let withdrawalSlippageInlineAlertAttributedText = AttributedString(localizerPathKey: "APP.VAULTS.SLIPPAGE_WARNING",
                                                                               params: ["LINK": DataLocalizer.localize(path: "APP.VAULTS.VAULT_FAQS"),
                                                                                        "AMOUNT": dydxFormatter.shared.percent(number: elevatedSlippageAmount, digits: 2) ?? "--"],
                                                                               // TODO: Replace
                                                                               hyperlinks: ["withdraw": "https://test.com",
                                                                                            "APP.VAULTS.VAULT_FAQS": "https://purple.com"],
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
                                                          params: ["AMOUNT": dydxFormatter.shared.percent(number: viewModel.elevatedSlippageAmount, digits: 2) ?? "--"]))
        }
    }

    private var submitButton: some View {
        let content: Text
        let state: PlatformButtonState
        switch viewModel.submitState {
        case .enabled:
            state = .primary
            content = Text(viewModel.transferType.confirmTransferText)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .base, fontSize: .large)
        case .disabled:
            state = .disabled
            content = Text(DataLocalizer.localize(path: "APP.VAULTS.ACKNOWLEDGE_HIGH_SLIPPAGE"))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .large)
        }
        return PlatformButtonViewModel(content: content.wrappedViewModel, state: state, action: viewModel.submitAction ?? {})
            .createView()
    }
}
