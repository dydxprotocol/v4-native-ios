//
//  dydxMultipleOrdersExistViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/4/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI

public class dydxMultipleOrdersExistViewModel: PlatformViewModel {
    @Published public var viewAllAction: (() -> Void)?

    public static var previewValue: dydxMultipleOrdersExistViewModel = {
        let vm = dydxMultipleOrdersExistViewModel()
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return HStack(spacing: 0) {
                Text(localizerPathKey: "APP.TRIGGERS_MODAL.MULTIPLE_ORDERS_FOUND")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontType: .base, fontSize: .medium)
                Spacer()
                Text(localizerPathKey: "APP.GENERAL.VIEW_ALL")
                    .themeColor(foreground: .colorPurple)
                    .themeFont(fontType: .plus, fontSize: .medium)
                    .onTapGesture { [weak self] in
                        self?.viewAllAction?()
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .borderAndClip(style: .cornerRadius(8), borderColor: .layer7)
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxMultipleOrdersExistViewModel_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxMultipleOrdersExistViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
