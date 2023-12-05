//
//  dydxRewardsHelpView.swift
//  dydxViews
//
//  Created by Michael Maguire on 12/5/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxRewardsHelpViewModel: dydxTitledCardViewModel {

    @Published public var faqs: [dydxFAQViewModel] = [] {
        didSet {
            listViewModel.items = faqs
        }
    }
    private let listViewModel = PlatformListViewModel()

    public init() {
        super.init(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.HELP", params: nil) ?? "",
                   verticalContentPadding: 0,
                   horizontalContentPadding: 0)
    }

    override func createContent(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        return listViewModel
            .createView()
        .wrappedInAnyView()
    }

    public static var previewValue: dydxRewardsHelpViewModel {
        let vm = dydxRewardsHelpViewModel()
        vm.faqs = [.previewValue]
        return vm
    }
}

#if DEBUG
struct dydxRewardsHelpViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxRewardsHelpViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxRewardsHelpViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxRewardsHelpViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
