//
//  dydxTradeValidationView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/25/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxValidationViewModel: PlatformViewModel {
    public enum ErrorType {
        case error, warning

        var isWarning: Bool {
            switch self {
            case .warning:
                return true
            default:
                return false
            }
        }
    }

    public enum State {
        case hide
        case showError
        case showReceipt

        var switchIconAssetName: String {
            switch self {
            case .showReceipt:
                return "icon_error"
            default:
                return "icon_receipt"
            }
        }
    }

    @Published public var title: String?
    @Published public var text: String?
    @Published public var state: State = .hide
    @Published public var errorType: ErrorType = .error
    @Published public var receiptViewModel: dydxReceiptViewModel? = dydxReceiptViewModel()

    public init() { }

    public static var previewValue: dydxValidationViewModel {
        let vm = dydxValidationViewModel()
        vm.title = "Excessive Leverage"
        vm.text = "This trade would place you close to the maximum allowed leverage. Try reducing the size of your position to 3 ETH or smaller."
        vm.state = .hide
        vm.receiptViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let title: String
            if self.state == .showReceipt {
                title = DataLocalizer.localize(path: "APP.TRADE.RECEIPT")
            } else {
                if let t = self.title {
                    title = t
                } else {
                    title = self.errorType.isWarning ?
                    DataLocalizer.localize(path: "APP.GENERAL.WARNING") :
                    DataLocalizer.localize(path: "APP.GENERAL.ERROR")
                }
            }
            return AnyView(
                VStack(alignment: .leading) {
                    if self.state != .hide {
                        HStack {
                            if self.state == .showError {
                                PlatformIconViewModel(type: .asset(name: "icon_error", bundle: Bundle.dydxView),
                                                      size: CGSize(width: 18, height: 18),
                                                      templateColor: self.errorType.isWarning ? .colorYellow : .colorRed)
                                .createView(parentStyle: style)
                            }

                            Text(title)
                                .themeColor(foreground: .textPrimary)
                                .themeFont(fontSize: .small)

                            Spacer()

                            let icon = PlatformIconViewModel(type: .asset(name: self.state.switchIconAssetName, bundle: Bundle.dydxView),
                                                             clip: .circle(background: .layer4, spacing: 14),
                                                             size: CGSize(width: 32, height: 32),
                                                             templateColor: .textTertiary)
                            PlatformButtonViewModel(content: icon,
                                                    type: .iconType,
                                                    action: { [weak self] in
                                if self?.state == .showError {
                                    self?.state = .showReceipt
                                } else if self?.state == .showReceipt {
                                    self?.state = .showError
                                }

                            })
                            .createView(parentStyle: style)
                        }
                    }

                    Group {
                        if self.state == .hide || self.state == .showReceipt {
                            self.receiptViewModel?.createView(parentStyle: style)
                                .frame(minWidth: 0)
                        } else {
                            ScrollView(showsIndicators: false) {
                                Text(self.text ?? "")
                                    .themeFont(fontSize: .small)
                            }
                            .frame(height: 132)
                        }
                    }
                }
                .animation(.default)
            )
        }
    }
}

#if DEBUG
struct dydxTradeValidationView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxValidationViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeValidationView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxValidationViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
