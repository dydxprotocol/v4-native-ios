//
//  LeverageRiskChange.swift
//  dydxViews
//
//  Created by Rui Huang on 11/14/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class LeverageRiskChangeModel: BeforeArrowAfterModel<LeverageRiskModel> {
    public convenience init(before: LeverageRiskModel?, after: LeverageRiskModel?) {
        self.init()

        self.before = before
        self.after = after
    }

    public override init() {
        super.init()

        before = LeverageRiskModel()
        after = LeverageRiskModel()

        changeDirection = {
            .orderedSame
        }
    }

    public static var previewValue: LeverageRiskChangeModel = {
        let vm = LeverageRiskChangeModel()
        vm.before = .previewValue
        vm.after = .previewValue
        vm.before?.level = .low
        vm.after?.level = .high
        return vm
    }()
}

#if DEBUG
struct LeverageRiskChange_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return LeverageRiskChangeModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct LeverageRiskChange_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return LeverageRiskChangeModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
