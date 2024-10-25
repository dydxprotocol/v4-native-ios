//
//  ComboBox.swift
//  dydxUI
//
//  Created by Rui Huang on 4/7/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI

public class ComboBoxModel: PlatformViewModel {
    @Published public var title: String?
    @Published public var content: PlatformViewModel?
    @Published public var onTapAction: (() -> Void)?

    public init() { }

    public init(title: String? = nil, content: PlatformViewModel? = nil, onTapAction: (() -> Void)? = nil) {
        self.title = title
        self.content = content
        self.onTapAction = onTapAction
    }

    public static var previewValue: ComboBoxModel {
        let vm = ComboBoxModel()
        vm.title = "Title"
        vm.content = Text("value").wrappedViewModel
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let main = VStack(alignment: .leading, spacing: 5) {
                if let title = self.title {
                    Text(title)
                        .themeFont(fontSize: .smaller)
                        .themeColor(foreground: .textTertiary)

                }

                self.content?.createView(parentStyle: style)
            }

            let trailing: PlatformViewModel
            if self.onTapAction != nil {
                trailing = PlatformIconViewModel(type: .asset(name: "combo_box_tick", bundle: Bundle(for: PlatformUIBundleClass.self)),
                                                 size: CGSize(width: 10, height: 10))
                .createView(parentStyle: style)
                .wrappedViewModel
            } else {
                trailing = PlatformView.nilViewModel
            }

            return AnyView(
                PlatformTableViewCellViewModel(leading: PlatformView.nilViewModel,
                                              logo: PlatformView.nilViewModel,
                                              main: main.wrappedViewModel,
                                              trailing: trailing)
                .createView(parentStyle: style)
                .themeColor(background: .layer4)
                .borderAndClip(style: .cornerRadius(12), borderColor: .borderDefault, lineWidth: 1)
                .onTapGesture { [weak self] in
                    self?.onTapAction?()
                }
            )
        }
    }
}

#if DEBUG
struct ComboBox_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            ComboBoxModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
