//
//  dydxVaultViewModel.swift
//  dydxViews
//
//  Created by Michael Maguire on 7/30/24.
//

import Foundation
import SwiftUI
import PlatformUI
import dydxFormatter
import Utilities

public class dydxVaultViewModel: PlatformViewModel {
    @Published public var vaultBalance: Double?
    @Published public var profitDollars: Double?
    @Published public var profitPercentage: Double?
    @Published public var cancelAction: (() -> Void)?
    @Published public var learnMoreAction: (() -> Void)?

    public init() { }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return AnyView(dydxVaultView(viewModel: self)).wrappedInAnyView()
        }
    }
}

private struct dydxVaultView: View {
    @ObservedObject var viewModel: dydxVaultViewModel

    var body: some View {
        VStack(spacing: 0) {
            titleRow
            Spacer().frame(height: 28)
            vaultPnlRow
            Spacer().frame(height: 16)
            Rectangle()
                .themeColor(foreground: .borderDefault)
                .frame(height: 1)
            Spacer(minLength: 16)
        }
        .frame(maxWidth: .infinity)
        .themeColor(background: .layer2)
    }

    // MARK: - Header
    var titleRow: some View {
        HStack(spacing: 16) {
            backButton
            titleImage
            titleText
            Spacer()
            learnMore
        }
        .padding(.horizontal, 12)
    }

    var backButton: some View {
        ChevronBackButtonModel(onBackButtonTap: viewModel.cancelAction ?? {})
            .createView()
    }

    var titleImage: some View {
        PlatformIconViewModel(type: .asset(name: "icon_token", bundle: .dydxView),
                              clip: .noClip,
                              size: .init(width: 40, height: 40),
                              templateColor: nil)
        .createView()
    }

    var titleText: some View {
        Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.VAULT", params: nil) ?? "")
            .themeColor(foreground: .textPrimary)
            .themeFont(fontType: .base, fontSize: .large)
    }

    var learnMore: some View {
        let image = Image("icon_external_link", bundle: .dydxView)
        return (Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.LEARN_MORE", params: nil) ?? "") + Text(" ") + Text(image))
            .themeColor(foreground: .textSecondary)
            .themeFont(fontType: .base, fontSize: .medium)
    }

    // MARK: - Section 1
    var vaultPnlRow: some View {
        HStack(spacing: 15) {
            vaultBalanceView
            pnlView
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
    }

    var vaultBalanceView: some View {
        VStack(spacing: 4) {
            Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.YOUR_VAULT_BALANCE", params: nil) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .smaller)
            Text(dydxFormatter.shared.dollar(number: viewModel.vaultBalance) ?? "--")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .base, fontSize: .medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        .borderAndClip(style: .cornerRadius(10), borderColor: .borderDefault)
    }

    var pnlView: some View {
        VStack(spacing: 4) {
            Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.YOUR_ALL_TIME_PNL", params: nil) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .smaller)
            VStack {
                VStack(spacing: 2) {
                    SignedAmountViewModel(text: dydxFormatter.shared.dollar(number: viewModel.profitDollars) ?? "--", sign: .none, coloringOption: .allText)
                        .createView()
                    if let profitPercentage = viewModel.profitPercentage {
                        Text(dydxFormatter.shared.percent(number: profitPercentage, digits: 2) ?? "")
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontType: .base, fontSize: .smaller)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .borderAndClip(style: .cornerRadius(10), borderColor: .borderDefault)
    }

}
