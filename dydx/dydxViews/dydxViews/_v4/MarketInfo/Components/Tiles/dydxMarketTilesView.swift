//
//  dydxMarketTileView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/10/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketTilesViewModel: PlatformViewModel {
    public struct TileViewModel {
        public init(text: String, icon: PlatformIconViewModel.IconType) {
            self.text = text
            self.icon = icon
        }

        let text: String
        let icon: PlatformIconViewModel.IconType
    }

    @Published public var allTiles: [TileViewModel] = []
    @Published public var onSelectionChanged: ((Int) -> Void)?
    @Published public var currentTile: Int = 0

    public init() { }

    public static var previewValue: dydxMarketTilesViewModel = {
        let vm = dydxMarketTilesViewModel()
        vm.allTiles = [
            .init(text: "Account", icon: .system(name: "heart.fill")),
            .init(text: "Price", icon: .system(name: "heart.fill"))
        ]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let items = self.allTiles.map { tile in
                PlatformIconViewModel(type: tile.icon,
                                      clip: .noClip,
                                      size: CGSize(width: 24, height: 24),
                                      templateColor: .textTertiary)
                .createView(parentStyle: style)
                .padding(8)
                .themeColor(background: .layer3)
                .border(borderWidth: 1, cornerRadius: 8, borderColor: ThemeColor.SemanticColor.layer5.color)
                .wrappedViewModel
            }
            let selectedItems = self.allTiles.map { tile in
                HStack {
                    PlatformIconViewModel(type: tile.icon,
                                          clip: .noClip,
                                          size: CGSize(width: 24, height: 24),
                                          templateColor: .textSecondary)
                        .createView(parentStyle: style)
                    Text(tile.text)
                        .themeFont(fontSize: .smaller)
                        .lineLimit(1)
                        // the text is clipped here to improve selection animation
                        .truncationMode(.noEllipsis)
                }
                .padding(8)
                .themeColor(foreground: .textPrimary)
                .themeColor(background: .layer0)
                .border(borderWidth: 1, cornerRadius: 8, borderColor: ThemeColor.SemanticColor.layer5.color)
                .wrappedViewModel
            }
            return AnyView(
                ScrollView {
                    TabGroupModel(items: items,
                                  selectedItems: selectedItems,
                                  currentSelection: self.currentTile,
                                  selectionAnimation: .easeInOut(duration: 0.1),
                                  onSelectionChanged: { [weak self] index in
                        self?.currentTile = index
                        self?.onSelectionChanged?(index)
                    },
                                  spacing: 8)
                    .createView(parentStyle: style)
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketTileView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTilesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketTileView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTilesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
