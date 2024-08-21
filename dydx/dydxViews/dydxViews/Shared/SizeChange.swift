//
//  SizeChange.swift
//  dydxViews
//
//  Created by Rui Huang on 10/19/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SizeChangeModel: BeforeArrowAfterModel<SizeTextModel> {
    public convenience init(before: SizeTextModel?, after: SizeTextModel?) {
        self.init()

        self.before = before
        self.after = after
    }

    public override init() {
        super.init()

        before = SizeTextModel()
        after = SizeTextModel()

        changeDirection = { [weak self] in
            guard let beforeAmount = self?.before?.size, let afterAmount = self?.after?.size else {
                return .orderedSame
            }
            return beforeAmount.compare(afterAmount)
        }
    }

    public static var previewValue: SizeChangeModel = {
        let vm = SizeChangeModel()
        vm.before = .previewValue
        vm.after = .previewValue
        vm.after?.size = NSNumber(value: 100)
        return vm
    }()
}

#if DEBUG
struct SizeChange_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SizeChangeModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SizeChange_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SizeChangeModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
