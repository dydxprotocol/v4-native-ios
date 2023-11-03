//
//  dydxDebugThemeViewerView.swift
//  dydxUI
//
//  Created by Michael Maguire on 7/24/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import Utilities
import PlatformUI

public class dydxDebugThemeViewerViewModel: PlatformViewModel {

    private struct ColorSection: Identifiable, Hashable {
        public let id = UUID()
        public let name: String
        public let colors: [ColorRow]
    }

    private struct ColorRow: Identifiable, Hashable {
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: dydxDebugThemeViewerViewModel.ColorRow, rhs: dydxDebugThemeViewerViewModel.ColorRow) -> Bool {
            lhs.id == rhs.id
        }

        public var id: String { name }
        public let name: String
        public let semanticColor: ThemeColor.SemanticColor

        init(semanticColor: ThemeColor.SemanticColor) {
            self.name = semanticColor.rawValue
            self.semanticColor = semanticColor
        }
    }

    @Published public var onBackButtonTap: (() -> Void)?
    @Published private var colorSections: [ColorSection] = [
        .init(name: "Layer", colors: [
            .layer0,
            .layer1,
            .layer2,
            .layer3,
            .layer4,
            .layer5,
            .layer6,
            .layer7,

            .colorPurple,
            .colorYellow,
            .colorGreen,
            .colorRed,
            .colorWhite,
            .colorBlack,
            .colorFadedGreen,
            .colorFadedRed,
            .colorFadedYellow,

            .transparent,
            .textPrimary,
            .textSecondary,
            .textTertiary,

            .borderDefault,
            .borderDestructive,
            .borderButton
            ]
                .map { ColorRow(semanticColor: $0) })

    ]

    public static var previewValue: dydxDebugThemeViewerViewModel = {
        let vm = dydxDebugThemeViewerViewModel()
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading) {
                ChevronBackButtonModel(onBackButtonTap: self.onBackButtonTap ?? {})
                    .createView(parentStyle: style)
                ScrollView {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        ForEach(self.colorSections) { colorSection in
                            Section {
                                VStack(alignment: .leading) {
                                    Text(colorSection.name)
                                    ForEach(colorSection.colors, id: \.self) { colorRow in
                                        HStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill( colorRow.semanticColor.color )
                                                .frame(width: 50, height: 50)
                                            Text(colorRow.name)
                                            Spacer()
                                        }
                                    }
                                    Spacer(minLength: 40)
                                }
                                .themeColor(background: .layer0)
                            }
                            .themeColor(background: .layer2)
                        }
                        .listRowInsets(EdgeInsets())
                        .themeColor(background: .layer0)
                    }
                    .navigationViewEmbedded(backgroundColor: ThemeColor.SemanticColor.layer2.color)
                    .ignoresSafeArea(edges: [.bottom])
                }
                .padding([.leading, .trailing])
            }

            return AnyView( view )
        }
    }
}

#if DEBUG
struct dydxDebugThemeViewerViewModel_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxDebugThemeViewerViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
