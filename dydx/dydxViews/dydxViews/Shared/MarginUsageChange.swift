//
//  MarginUsageChange.swift
//  dydxViews
//
//  Created by Rui Huang on 10/18/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class MarginUsageChangeModel: BeforeArrowAfterModel<MarginUsageModel> {
    public convenience init(before: MarginUsageModel?, after: MarginUsageModel?) {
        self.init()

        self.before = before
        self.after = after
    }

    public override init() {
        super.init()

        before = MarginUsageModel()
        after = MarginUsageModel()

        changeDirection = { [weak self] in
            guard let before = self?.before, let after = self?.after else {
                return .orderedSame
            }
            return NSNumber(value: after.percent).compare(NSNumber(value: before.percent))
        }
    }

    public static var previewValue: MarginUsageChangeModel = {
        let vm = MarginUsageChangeModel()
        vm.before = .previewValue
        vm.after = .previewValue
        vm.before?.percent = 0.2
        vm.after?.percent = 0.7
        return vm
    }()
}

#if DEBUG
struct MarginUsageChange_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return MarginUsageChangeModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct MarginUsageChange_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return MarginUsageChangeModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
