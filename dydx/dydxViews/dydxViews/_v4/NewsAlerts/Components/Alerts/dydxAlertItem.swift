//
//  dydxAlertItem.swift
//  dydxUI
//
//  Created by Rui Huang on 5/3/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAlertItemModel: PlatformViewModel, Equatable {
    public static func == (lhs: dydxAlertItemModel, rhs: dydxAlertItemModel) -> Bool {
        lhs.title == rhs.title &&
        lhs.message == rhs.message
    }

    @Published public var title: String?
    @Published public var message: String?
    @Published public var icon: PlatformIconViewModel?
    @Published public var tapAction: (() -> Void)?
    @Published public var deletionAction: (() -> Void)?

    public init(title: String? = nil, message: String? = nil, icon: PlatformIconViewModel? = nil, tapAction: (() -> Void)? = nil, deletionAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.icon = icon
        self.tapAction = tapAction
        self.deletionAction = deletionAction
    }

    public static var previewValue: dydxAlertItemModel {
        let vm = dydxAlertItemModel()
        vm.title = "Title"
        vm.message = "Message message ..."
        vm.icon = PlatformIconViewModel(type: .system(name: "heart.fill"))
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = VStack(alignment: .leading, spacing: 4) {
                Text(self.title ?? "")
                    .themeFont(fontSize: .medium)
                if let message = self.message {
                    Text(message)
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .small)
                }
            }

            let cell = HStack(spacing: 16) {
                self.icon?.createView(parentStyle: style)
                main
                Spacer()
            }
                .padding(16)
                .themeColor(background: .layer4)
                .cornerRadius(16, corners: .allCorners)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeColor.SemanticColor.layer6.color, lineWidth: 2)
                )
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .onTapGesture { [weak self] in
                    self?.tapAction?()
                }

            if self.deletionAction != nil {
                let rightCellSwipeAccessoryView = PlatformIconViewModel(type: .asset(name: "action_cancel", bundle: Bundle.dydxView), size: .init(width: 16, height: 16))
                    .createView(parentStyle: style, styleKey: styleKey)
                    .tint(ThemeColor.SemanticColor.layer2.color)

                let rightCellSwipeAccessory = CellSwipeAccessory(accessoryView: AnyView(rightCellSwipeAccessoryView)) {
                    self.deletionAction?()
                }
                return AnyView(
                    cell.swipeActions(leftCellSwipeAccessory: nil, rightCellSwipeAccessory: rightCellSwipeAccessory)
                )
            } else {
                return AnyView(cell)
            }
        }
    }
}

#if DEBUG
struct dydxAlertItem_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAlertItemModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAlertItem_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAlertItemModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
