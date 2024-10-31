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
            PlatformIconViewModel(type: .asset(name: "icon_help", bundle: Bundle.dydxView),
                                  clip: .circle(background: .layer4, spacing: 10, borderColor: ThemeColor.SemanticColor.layer5),
                                  templateColor: ThemeColor.SemanticColor.textSecondary)
                .createView()
                .onTapGesture {
                    viewModel.learnMoreAction?()
                }
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

    @ViewBuilder
    private var learnMore: some View {
        if let learnMoreAction = viewModel.learnMoreAction {
            let image = Image("icon_external_link", bundle: .dydxView)
            (Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.LEARN_MORE", params: nil) ?? "") + Text(" ") + Text(image))
                .themeColor(foreground: .textSecondary)
                .themeFont(fontType: .base, fontSize: .medium)
                .padding(.trailing, 12)
                .onTapGesture {
                    learnMoreAction()
                }
        }
    }

    // MARK: - Section 1 - PNL
    private var vaultPnlRow: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                vaultBalanceView
                pnlView
            }
            .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                withdrawButton
                depositButton
            }
        }
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
            Text(dydxFormatter.shared.percent(number: viewModel.thirtyDayReturnPercent, digits: 0) ?? "")
                .themeColor(foreground: ThemeSettings.directionalColor(forValue: viewModel.thirtyDayReturnPercent))
                .themeFont(fontType: .base, fontSize: .medium)
        }
    }

    private var tvlTitleValue: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DataLocalizer.shared?.localize(path: "APP.VAULTS.TVL", params: nil) ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .small)
            Text(dydxFormatter.shared.dollar(number: viewModel.totalValueLocked, digits: 0) ?? "")
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
            Spacer().frame(height: 12)
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
                let sizeText = DataLocalizer.shared?.localize(path: "APP.GENERAL.SIZE", params: nil) ?? ""
                let equityText = DataLocalizer.shared?.localize(path: "APP.GENERAL.EQUITY", params: nil) ?? ""
                Text(sizeText + " / " + equityText)
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
        ForEach(viewModel.positions ?? [], id: \.marketId) { position in
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
        let textColor: ThemeColor.SemanticColor = viewModel.withdrawAction == nil ? .textTertiary : .textPrimary
        let content = HStack(spacing: 8) {
            PlatformIconViewModel(type: .asset(name: "icon_transfer_withdrawal", bundle: .dydxView),
                                  size: .init(width: 20, height: 20),
                                  templateColor: textColor)
                .createView()
            Text(localizerPathKey: "APP.GENERAL.WITHDRAW")
                .themeFont(fontType: .plus, fontSize: .medium)
                .themeColor(foreground: textColor)
        }
        .wrappedViewModel

        PlatformButtonViewModel(content: content,
                                type: .defaultType(),
                                state: viewModel.withdrawAction == nil ? .disabled : .secondary,
                                action: { viewModel.withdrawAction?() })
        .createView()
    }

    @ViewBuilder
    private var depositButton: some View {
        let textColor: ThemeColor.SemanticColor = viewModel.withdrawAction == nil ? .textTertiary : .textPrimary
        let content = HStack(spacing: 8) {
            PlatformIconViewModel(type: .asset(name: "icon_transfer_deposit", bundle: .dydxView),
                                  size: .init(width: 20, height: 20),
                                  templateColor: textColor)
                .createView()
            Text(localizerPathKey: "APP.GENERAL.DEPOSIT")
                .themeFont(fontType: .plus, fontSize: .medium)
                .themeColor(foreground: textColor)
        }
        .wrappedViewModel

        PlatformButtonViewModel(content: content,
                                type: .defaultType(),
                                state: viewModel.depositAction == nil ? .disabled : .primary,
                                action: { viewModel.depositAction?() })
        .createView()
    }
}
