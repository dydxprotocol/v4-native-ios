//
//  dydxRateAppView.swift
//  dydxUI
//
//  Created by Michael Maguire on 2/28/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI

public class dydxRateAppViewModel: PlatformViewModel {
    @Published public var text: String?

    public static var previewValue: dydxRateAppViewModel = {
        let vm = dydxRateAppViewModel()
        vm.text = "Test String"
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Text(self.text ?? "")
            )
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
