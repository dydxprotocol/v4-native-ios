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
        case enabled(String)
        case disabled(String)
    }
    
    public let submitState: State
    public var submitAction: (() -> Void)?
    
    @Published public private(set) var numberFormatter = dydxNumberInputFormatter()
    
    @Published fileprivate var selected: VaultTransferType
    @Published fileprivate var amount: Double?
    fileprivate var maxAmount: Double = 0
    
    public var inputReceiptChangeItems: [dydxReceiptChangeItemView]?
    public var inputInlineAlert: InlineAlertViewModel?
    public var buttonReceiptChangeItems: [dydxReceiptChangeItemView]?
    
    public init(initialSelection: VaultTransferType, submitState: State) {
        self.selected = initialSelection
        self.submitState = submitState
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return VaultDepositWithdrawView(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

public enum VaultTransferType: CaseIterable, RadioButtonContentDisplayable {
    case deposit
    case withdraw
    
    var displayText: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT")
        case .withdraw: return DataLocalizer.localize(path: "APP.GENERAL.WITHDRAW")
        }
    }
    
    public var inputFieldTitle: String {
        switch self {
        case .deposit: return DataLocalizer.localize(path: "APP.VAULTS.ENTER_AMOUNT_TO_DEPOSIT")
        case .withdraw: return DataLocalizer.localize(path: "APP.VAULTS.ENTER_AMOUNT_TO_WITHDRAW")
        }
    }
}

fileprivate struct VaultDepositWithdrawView: View {
    @ObservedObject var viewModel: dydxVaultDepositWithdrawViewModel
    
    var options = VaultTransferType.allCases
    
    private var radioButtonSelector: some View {
        RadioButtonGroup(selected: $viewModel.selected,
                         options: options,
                         buttonClipStyle: .capsule,
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
    }
    
    private var inputArea: some View {
        VStack(spacing: 16) {
            dydxTitledNumberField(title: viewModel.selected.inputFieldTitle,
                                  accessoryTitle: nil,
                                  numberFormatter: viewModel.numberFormatter,
                                  minValue: 0,
                                  maxValue: viewModel.maxAmount,
                                  isMaxButtonVisible: true,
                                  value: $viewModel.amount)
            VStack(spacing: 8) {
                ForEach(self.viewModel.inputReceiptChangeItems ?? [], id: \.id) { $0.createView() }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .themeColor(background: .layer2)
        .clipShape(.rect(cornerRadius: 10))
    }
    
    private var submitButton: some View {
        let content: Text
        let state: PlatformButtonState
        switch viewModel.submitState {
        case .enabled(let text):
            state = .primary
            content = Text(text)
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .base, fontSize: .large)
        case .disabled(let text):
            state = .disabled
            content = Text(text)
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .large)
        }
        return PlatformButtonViewModel(content: content.wrappedViewModel, state: state, action: viewModel.submitAction ?? {})
            .createView()
    }
    
    private var buttonArea: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                ForEach(self.viewModel.buttonReceiptChangeItems ?? [], id: \.id) { $0.createView() }
            }
            .padding(.horizontal, 16)
            submitButton
        }
        .padding(.top, 16)
        .themeColor(background: .layer2)
        .clipShape(.rect(cornerRadius: 10))
    }
}
