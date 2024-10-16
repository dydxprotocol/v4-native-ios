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
    @Published public var allTimeReturnUsdc: Double?
    @Published public var thirtyDayReturnPercent: Double?
    @Published public var totalValueLocked: Double?
    @Published public var vaultChart: dydxVaultChartViewModel?
    @Published public var positions: [dydxVaultPositionViewModel]?
    @Published public var cancelAction: (() -> Void)?
    @Published public var learnMoreAction: (() -> Void)?
    @Published public var withdrawAction: (() -> Void)?
    @Published public var depositAction: (() -> Void)?

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return AnyView(dydxVaultView(viewModel: self))
                .wrappedInAnyView()
        }
    }
}

private struct dydxVaultView: View {
    @ObservedObject var viewModel: dydxVaultViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Spacer().frame(height: 12)
                titleRow
                Spacer().frame(height: 20)
                ScrollView {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        VStack(spacing: 0) {
                            vaultPnlRow
                            Spacer().frame(height: 16)
                            div
                            Spacer().frame(height: 16)
                            aprTvlRow
                            Spacer().frame(height: 16)
                            div
                            Spacer().frame(height: 16)
                            chart
                            Spacer().frame(height: 16)
                            div
                            Spacer().frame(height: 16)
                        }
                        Section(header: positionsStickyHeader) {
                            positionsList
                            Spacer().frame(height: 96)
                        }
                    }
                }
            }
            buttonStack
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .themeColor(background: .layer2)
    }

    private var div: some View {
        Rectangle()
            .themeColor(foreground: .borderDefault)
            .frame(height: 1)
    }

    // MARK: - Header
    private var titleRow: some View {
        HStack(spacing: 16) {
            titleImage
            titleText
            Spacer()
            learnMore
        }
        .padding(.horizontal, 16)
    }

    private var titleImage: some View {
        PlatformIconViewModel(type: .asset(name: "icon_chain", bundle: .dydxView),
                              clip: .noClip,
                              size: .init(width: 40, height: 40),
                              templateColor: nil)
        .createView()
    }

    private var titleText: some View {
        Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.MEGAVAULT", params: nil) ?? "")
            .themeColor(foreground: .textPrimary)
            .themeFont(fontType: .plus, fontSize: .largest)
    }

    private var learnMore: some View {
        let image = Image("icon_external_link", bundle: .dydxView)
        return (Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.LEARN_MORE", params: nil) ?? "") + Text(" ") + Text(image))
            .themeColor(foreground: .textSecondary)
            .themeFont(fontType: .base, fontSize: .medium)
            .padding(.trailing, 12)
    }

    // MARK: - Section 1 - PNL
    private var vaultPnlRow: some View {
        HStack(spacing: 15) {
            vaultBalanceView
            pnlView
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
    }

    private var vaultBalanceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.YOUR_VAULT_BALANCE", params: nil) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .small)
            Spacer(minLength: 4)
            Text(dydxFormatter.shared.dollar(number: viewModel.vaultBalance) ?? "--")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .base, fontSize: .medium)
        }
        .leftAligned()
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .borderAndClip(style: .cornerRadius(10), borderColor: .borderDefault)
    }

    private var pnlView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.YOUR_ALL_TIME_PNL", params: nil) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .small)
            Spacer(minLength: 4)
            Text(dydxFormatter.shared.dollar(number: viewModel.allTimeReturnUsdc) ?? "--")
                .themeColor(foreground: viewModel.allTimeReturnUsdc == nil ? .textPrimary : ThemeSettings.directionalColor(forValue: viewModel.allTimeReturnUsdc))
                .themeFont(fontType: .base, fontSize: .medium)
        }
        .leftAligned()
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .borderAndClip(style: .cornerRadius(10), borderColor: .borderDefault)
    }

    // MARK: - Section 2 - APR/TVL
    private var aprTvlRow: some View {
        HStack(spacing: 32) {
            aprTitleValue
            tvlTitleValue
        }
        .leftAligned()
        .padding(.horizontal, 16)
    }

    private var aprTitleValue: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.VAULT_THIRTY_DAY_APR", params: nil) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .small)
            Text(dydxFormatter.shared.percent(number: viewModel.thirtyDayReturnPercent, digits: 2) ?? "")
                .themeColor(foreground: ThemeSettings.directionalColor(forValue: viewModel.thirtyDayReturnPercent))
                .themeFont(fontType: .base, fontSize: .medium)
        }
    }

    private var tvlTitleValue: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.TVL", params: nil) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .small)
            Text(dydxFormatter.shared.dollar(number: viewModel.totalValueLocked) ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontType: .base, fontSize: .medium)
        }
    }

    // MARK: - Section 3 - graph
    private var chart: some View {
        viewModel.vaultChart?
            .createView()
            .frame(height: 174)
    }

    // MARK: - Section 4 - positions
    private var openPositionsHeader: some View {
        HStack(spacing: 8) {
            Text(DataLocalizer.shared?.localize(path: "APP.TRADE.OPEN_POSITIONS", params: nil) ?? "")
                .themeColor(foreground: .textSecondary)
                .themeFont(fontType: .base, fontSize: .larger)
            Text("\(viewModel.positions?.count ?? 0)")
                .themeColor(foreground: .textSecondary)
                .themeFont(fontType: .base, fontSize: .small)
                .padding(.vertical, 2.5)
                .padding(.horizontal, 6.5)
                .themeColor(background: .layer6)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .leftAligned()
        .padding(.horizontal, 16)
    }

    private var positionsStickyHeader: some View {
        VStack(spacing: 0) {
            openPositionsHeader
            Spacer().frame(height: 8)
            div
            Spacer().frame(height: 16)
            positionsColumnsHeader
            Spacer().frame(height: 8)
        }
        .themeColor(background: .layer2)
    }

    private var positionsColumnsHeader: some View {
        HStack(spacing: VaultPositionView.interSectionPadding) {
            Group {
                Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.MARKET", params: nil) ?? "")
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontType: .base, fontSize: .small)
                    .leftAligned()
                    .frame(width: VaultPositionView.marketSectionWidth)
                    .lineLimit(1)
                Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.SIZE", params: nil) ?? "")
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontType: .base, fontSize: .small)
                    .lineLimit(1)
                Spacer()
                Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.VAULT_THIRTY_DAY_PNL", params: nil) ?? "")
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontType: .base, fontSize: .small)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.trailing, VaultPositionView.pnlSpacing + VaultPositionView.sparklineWidth)
            }
        }
        .padding(.horizontal, 16)
    }

    private var positionsList: some View {
        ForEach(viewModel.positions ?? [], id: \.id) { position in
            position.createView()
                .centerAligned()
                .frame(height: 53)
            div
        }
        .padding(.horizontal, 16)
    }

    // MARK: Floating Buttons
    @ViewBuilder
    private var withdrawButton: some View {
        if let withdrawAction = viewModel.withdrawAction {
            let content = Text(localizerPathKey: "APP.GENERAL.WITHDRAW")
                .themeFont(fontType: .plus, fontSize: .medium)
                .themeColor(foreground: .textPrimary)
                .wrappedViewModel

            PlatformButtonViewModel(content: content,
                                    type: .defaultType(),
                                    state: .secondary,
                                    action: withdrawAction)
            .createView()
        }
    }

    @ViewBuilder
    private var depositButton: some View {
        if let depositAction = viewModel.depositAction {
            let content = Text(localizerPathKey: "APP.GENERAL.DEPOSIT")
                .themeFont(fontType: .plus, fontSize: .medium)
                .themeColor(foreground: .textPrimary)
                .wrappedViewModel

            PlatformButtonViewModel(content: content,
                                    type: .defaultType(),
                                    state: .primary,
                                    action: depositAction)
            .createView()
        }
    }

    private var buttonStack: some View {
        HStack(spacing: 12) {
            withdrawButton
            depositButton
        }
        .padding(.horizontal, 16)
    }
}
