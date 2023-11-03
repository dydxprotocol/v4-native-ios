//
//  dydxTradeStatusLogoView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/27/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import UIToolkits

public class dydxTradeStatusLogoViewModel: PlatformViewModel {
    public enum StatusIcon {
        case submitting, pending, open, filled, failed
    }

    @Published public var status = StatusIcon.submitting
    @Published public var title = ""
    @Published public var detail = ""

    private lazy var largeStatusIcon: SpinImageView = {
        let largeStatusIcon = SpinImageView()
        largeStatusIcon.rotating = false
        return largeStatusIcon
    }()

    public init() { }

    public static var previewValue: dydxTradeStatusLogoViewModel {
        let vm = dydxTradeStatusLogoViewModel()
        vm.title = "Status"
        vm.detail = "Your trade was executed"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            self.updateStatusIcon()
            return AnyView(
                VStack(spacing: 16) {
                    self.largeStatusIcon.swiftUIView
                        .frame(width: 84, height: 84)
                        .padding(.top, 32)

                    Text(self.title)
                        .themeFont(fontSize: .largest)
                        .themeColor(foreground: .textPrimary)

                    Text(self.detail)
                        .themeFont(fontSize: .medium)
                }
            )
        }
    }

    private func updateStatusIcon() {
        switch status {
        case .submitting:
            largeStatusIcon.image = UIImage(named: "order_status_pending", in: Bundle.dydxView, with: nil)
            largeStatusIcon.rotating = true
        case .pending:
            largeStatusIcon.image = UIImage(named: "order_status_pending", in: Bundle.dydxView, with: nil)
            largeStatusIcon.rotating = false
        case .open:
            largeStatusIcon.image = UIImage(named: "order_status_open", in: Bundle.dydxView, with: nil)
            largeStatusIcon.rotating = false
        case .failed:
            largeStatusIcon.image = UIImage(named: "order_status_fail", in: Bundle.dydxView, with: nil)
            largeStatusIcon.rotating = false
        case .filled:
            largeStatusIcon.image = UIImage(named: "order_status_filled", in: Bundle.dydxView, with: nil)
            largeStatusIcon.rotating = false
        }
    }
}

#if DEBUG
struct dydxTradeStatusLogoView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeStatusLogoViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeStatusLogoView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeStatusLogoViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
