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
    @Published public var learnMoreTapped: (() -> Void)?
    private let listViewModel = PlatformListViewModel()

    public init() {
        super.init(title: DataLocalizer.shared?.localize(path: "APP.GENERAL.HELP", params: nil) ?? "",
                   verticalContentPadding: 0,
                   horizontalContentPadding: 0)
    }

    public override func createTitleAccessoryView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        HStack {
            Text(DataLocalizer.shared?.localize(path: "APP.GENERAL.LEARN_MORE", params: nil) ?? "")
                    .themeColor(foreground: .textSecondary)
                    .themeFont(fontType: .text, fontSize: .small)
            PlatformIconViewModel(type: .asset(name: "icon_link", bundle: .dydxView),
                                  clip: .noClip,
                                  size: .init(width: 16, height: 16),
                                  templateColor: .textSecondary)
                .createView()
        }
        .onTapGesture { [weak self] in
            self?.learnMoreTapped?()
        }
        .wrappedInAnyView()
    }

    public override func createContentView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> AnyView? {
        listViewModel
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
