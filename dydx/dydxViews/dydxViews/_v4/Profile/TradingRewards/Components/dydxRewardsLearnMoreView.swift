//
//  dydxRewardsLearnMoreView.swift
//  dydxUI
//
//  Created by Michael Maguire on 12/8/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Utilities
import SwiftUI
import PlatformUI

public class dydxRewardsLearnMoreViewModel: PlatformViewModel {
    private let title: String
    private let description: String
    private let tapAction: () -> Void

    public init(title: String, description: String, tapAction: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.tapAction = tapAction
    }

    public static var previewValue: dydxRewardsLearnMoreViewModel = {
        let vm = dydxRewardsLearnMoreViewModel(title: "test", description: "description", tapAction: {})
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(self.title)
                        .themeFont(fontType: .text, fontSize: .medium)
                        .themeColor(foreground: .textPrimary)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(self.description)
                            .themeFont(fontType: .text, fontSize: .small)
                            .themeColor(foreground: .textTertiary)
                        Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.LEARN_MORE_ARROW", params: nil) ?? "")
                            .themeFont(fontType: .text, fontSize: .small)
                            .themeColor(foreground: .textSecondary)
                    }
                }.leftAligned()
                Spacer(minLength: 16)
                PlatformIconViewModel(type: .asset(name: "icon_next", bundle: .dydxView),
                                      clip: .circle(background: .layer4, spacing: 12, borderColor: .layer6),
                                      size: .init(width: 28, height: 28),
                                      templateColor: .textTertiary)
                .createView(parentStyle: parentStyle)
            }
            .padding(.all, 16)
            .themeColor(background: .layer3)
            .onTapGesture(perform: self.tapAction)
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxRewardsLearnMoreView_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxRewardsLearnMoreViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
