//
//  Tooltip.swift
//  dydxUI
//
//  Created by Rui Huang on 05/02/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class TooltipModel: PlatformViewModel {
    @Published public var label: PlatformViewModel?
    @Published public var content: PlatformViewModel?

    @Published private var presented: Bool = false
    private lazy var presentedBindng = Binding(
        get: { [weak self] in self?.presented == true },
        set: { [weak self] in self?.presented = $0 }
    )

    public init() { }

    public static var previewValue: TooltipModel {
        let vm = TooltipModel()
        vm.label = Text("Test String").wrappedViewModel
        vm.content = Text("Content").wrappedViewModel
        return vm
    }

    public func dismiss() {
        presented = false
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = label?.createView(parentStyle: style)                .onTapGesture { [weak self] in
                    self?.presented.toggle()
                }
                .popover(present: presentedBindng, attributes: {
                    $0.position = .absolute(
                          originAnchor: .top,
                          popoverAnchor: .bottom
                      )
                    $0.sourceFrameInset = .init(top: 0, left: 0, bottom: -16, right: 0)
                    $0.presentation.animation = .none
                    $0.blocksBackgroundTouches = true
                    $0.onTapOutside = { [weak self] in
                        self?.presented = false
                    }
                }, view: {
                    VStack {
                        self.content?.createView(parentStyle: style)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .cornerRadius(8), borderColor: .layer6, lineWidth: 1)
                    .environmentObject(ThemeSettings.shared)
                })

            return AnyView(view)
        }
    }
}

#if DEBUG
struct Tooltip_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return TooltipModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct Tooltip_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return TooltipModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
