//
//  dydxSearchView.swift
//  dydxUI
//
//  Created by Rui Huang on 4/10/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSearchViewModel: PlatformViewModel {
    public enum PresentationStyle {
        case pushed
        case modal
    }

    @Published public var presentationStyle = PresentationStyle.modal
    @Published public var itemList: PlatformListViewModel? = PlatformListViewModel(intraItemSeparator: false)
    @Published public var searchText: String = ""
    @Published public var cancelAction: (() -> Void)?

    private lazy var searchTextBinding = Binding(
        get: {
            self.searchText
        },
        set: {
            self.searchText = $0
        }
    )

    public static var previewValue: dydxSearchViewModel = {
        let vm = dydxSearchViewModel()
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack {
                    self.createSearchBar(style: style)

                    if self.itemList?.items.count ?? 0 > 0 {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(pinnedViews: [.sectionHeaders]) {
                                self.itemList?
                                    .createView(parentStyle: style)
                            }
                        }
                        .keyboardObserving()
                    } else {
                        HStack {
                            Spacer()
                            Text(DataLocalizer.localize(path: "APP.GENERAL.START_SEARCH"))
                                .themeFont(fontType: .plus, fontSize: .larger)
                                .themeColor(foreground: .textTertiary)
                            Spacer()
                        }
                        .padding(.top, 120)
                    }

                    Spacer()
                }
                .padding([.leading, .trailing])
                .padding(.top, 32)
                .padding(.bottom, self.safeAreaInsets?.bottom)
                .themeColor(background: .layer2)
                .makeSheet()
                .ignoresSafeArea(edges: [.bottom])
            )
        }
    }

    private func createSearchBar(style: ThemeStyle) -> AnyView {
        AnyView(
            HStack {
                if presentationStyle == .pushed {
                    ChevronBackButtonModel(onBackButtonTap: self.cancelAction ?? {})
                        .createView(parentStyle: style)
                }

                PlatformInputModel(value: self.searchTextBinding,
                                   currentValue: self.searchText,
                                   placeHolder: DataLocalizer.localize(path: "APP.GENERAL.SEARCH"),
                                   keyboardType: .default,
                                   focusedOnAppear: true)
                    .createView(parentStyle: style)
                    .frame(height: 40)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 12)
                    .themeColor(background: .layer3)
                    .clipShape(Capsule())

                if presentationStyle == .modal {
                    PlatformButtonViewModel(content: PlatformIconViewModel(type: .asset(name: "icon_cancel", bundle: Bundle.dydxView),
                                                                           clip: .circle(background: .layer3, spacing: 24, borderColor: .layer6),
                                                                           size: CGSize(width: 42, height: 42)),
                                            type: .iconType,
                                            action: self.cancelAction ?? {})
                    .createView(parentStyle: style)
                }
            }
            .padding(.vertical, 8)
        )
    }
}

#if DEBUG
struct dydxSearchView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSearchViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSearchView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSearchViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
