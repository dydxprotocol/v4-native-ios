//
//  dydxRateAppView.swift
//  dydxUI
//
//  Created by Michael Maguire on 2/28/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxRateAppViewModel: PlatformViewModel {
    @Published public var positiveRatingIntentAction: (() -> Void)?
    @Published public var negativeRatingIntentAction: (() -> Void)?
    @Published public var deferAction: (() -> Void)?

    public static var previewValue: dydxRateAppViewModel = {
        let vm = dydxRateAppViewModel()
        return vm
    }()

    private func createButtonContent(title: String, parentStyle: ThemeStyle, styleKey: String?, action: (() -> Void)?) -> PlatformView {
        PlatformButtonViewModel(
            content: Text(title).wrappedViewModel,
            state: .secondary,
            action: { action?() })
        .createView(parentStyle: parentStyle, styleKey: styleKey)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return VStack(alignment: .center, spacing: 24) {
                        Text(DataLocalizer.shared?.localize(path: "RATE_APP.QUESTION", params: nil) ?? "")
                            .themeFont(fontType: .base, fontSize: .large)
                            .themeColor(foreground: .textSecondary)
                        HStack(spacing: 16) {
                            self.createButtonContent(title: DataLocalizer.shared?.localize(path: "RATE_APP.YES", params: nil) ?? "",
                                                     parentStyle: parentStyle,
                                                     styleKey: styleKey,
                                                     action: self.positiveRatingIntentAction)
                            self.createButtonContent(title: DataLocalizer.shared?.localize(path: "RATE_APP.NO", params: nil) ?? "",
                                                     parentStyle: parentStyle,
                                                     styleKey: styleKey,
                                                     action: self.negativeRatingIntentAction)
                        }
                        Text(DataLocalizer.shared?.localize(path: "RATE_APP.DEFER", params: nil) ?? "")
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .medium)
                            .onTapGesture {[weak self] in
                                self?.deferAction?()
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 46)
                    .themeColor(background: .layer4)
                    .makeSheet(sheetStyle: .fitSize)
                    .ignoresSafeArea(edges: .bottom)
                    .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxRateAppView_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxRateAppViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
