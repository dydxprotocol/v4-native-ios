//
//  TransferInstanceViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 9/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class TransferInstanceViewModel: PlatformViewModel {
    public enum TransferType {
        case deposit
        case withdrawal
        case transferIn
        case transferOut

        fileprivate var displayText: String {
            switch self {
            case .deposit: return DataLocalizer.localize(path: "APP.GENERAL.DEPOSIT")
            case .withdrawal: return DataLocalizer.localize(path: "APP.GENERAL.WITHDRAW")
            case .transferIn: return DataLocalizer.localize(path: "APP.GENERAL.TRANSFER_IN")
            case .transferOut: return DataLocalizer.localize(path: "APP.GENERAL.TRANSFER_OUT")
            }
        }

        fileprivate var iconName: String {
            switch self {
            case .deposit, .transferIn: return "icon_transfer_deposit"
            case .withdrawal, .transferOut: return "icon_transfer_withdrawal"
            }
        }

        fileprivate var sign: PlatformUISign {
            switch self {
            case .deposit, .transferIn: return .plus
            case .withdrawal, .transferOut: return .minus
            }
        }
    }

    private let date: Date
    private let type: TransferType
    private let amount: Double
    private let addressDisplay: String

    public init(date: Date, type: TransferType, amount: Double, fromAddress: String, toAddress: String) {
        self.date = date
        self.type = type
        self.amount = amount
        if type == .deposit || type == .transferIn {
            addressDisplay = DataLocalizer.localize(path: "APP.GENERAL.FROM", params: ["FROM": TransferInstanceViewModel.getTruncatedAddress(address: fromAddress)])
        } else {
            addressDisplay = DataLocalizer.localize(path: "APP.GENERAL.TO", params: ["TO": TransferInstanceViewModel.getTruncatedAddress(address: toAddress)])
        }
    }

    private static func getTruncatedAddress(address: String) -> String {
        address.prefix(6) + "..." + address.suffix(4)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let icon = self.createLogo(parentStyle: style)
            let main = self.createMain(parentStyle: style)
            let trailing = self.createTrailing(parentStyle: style)

            return AnyView(
                PlatformTableViewCellViewModel(logo: icon.wrappedViewModel,
                                               main: main.wrappedViewModel,
                                               trailing: trailing.wrappedViewModel)
                .createView(parentStyle: parentStyle)
            )
        }
    }

    private func createLogo(parentStyle: ThemeStyle) -> some View {
        IntervalTextModel(date: date)
            .createView(parentStyle: parentStyle
                                        .themeFont(fontSize: .smaller)
                                        .themeColor(foreground: .textTertiary))
            .frame(width: 32)
            .themeFont(fontSize: .small)
    }

    private func createMain(parentStyle: ThemeStyle) -> some View {
        HStack {
            PlatformIconViewModel(type: .asset(name: type.iconName, bundle: Bundle.dydxView),
                                  clip: .circle(background: .layer3, spacing: 14),
                                  size: CGSize(width: 34, height: 34),
                                  templateColor: .textSecondary)
            .createView(parentStyle: parentStyle)

            Text(type.displayText)
                    .themeFont(fontSize: .large)
        }
    }

    private func createTrailing(parentStyle: ThemeStyle) -> some View {
        VStack(alignment: .trailing) {
            Text(addressDisplay)
                .themeFont(fontSize: .smaller)
                .themeColor(foreground: .textTertiary)
                .lineLimit(1)
            SignedAmountViewModel(text: dydxFormatter.shared.dollarVolume(number: amount.magnitude), sign: type.sign, coloringOption: .signOnly)
                .createView(parentStyle: parentStyle)
                .themeFont(fontSize: .small)
        }
    }

}
