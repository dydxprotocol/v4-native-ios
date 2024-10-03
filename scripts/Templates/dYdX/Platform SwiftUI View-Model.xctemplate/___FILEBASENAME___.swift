//
//  ___FILEBASENAMEASIDENTIFIER___.swift
//  dydxUI
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ dYdX Trading Inc. All rights reserved.
//

import SwiftUI

public class ___FILEBASENAMEASIDENTIFIER___Model: PlatformViewModel {
    @Published public var text: String?

    public static var previewValue: ___FILEBASENAMEASIDENTIFIER___Model = {
        let vm = ___FILEBASENAMEASIDENTIFIER___Model()
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
struct ___FILEBASENAMEASIDENTIFIER____Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            ___FILEBASENAMEASIDENTIFIER___Model.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
