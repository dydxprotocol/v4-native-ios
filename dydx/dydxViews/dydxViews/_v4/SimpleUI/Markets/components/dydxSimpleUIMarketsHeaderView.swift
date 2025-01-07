//
//  dydxSimpleUIMarketsHeaderView.swift
//  dydxUI
//
//  Created by Rui Huang on 05/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIMarketsHeaderViewModel: PlatformViewModel {
    public struct MenuItem: Hashable, Equatable {
        public init(icon: String, title: String, action: @escaping () -> Void) {
            self.icon = icon
            self.title = title
            self.action = action
        }

        public var icon: String
        public var title: String
        public var action: () -> Void

        public func hash(into hasher: inout Hasher) {
            hasher.combine(icon)
            hasher.combine(title)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.icon == rhs.icon &&
            lhs.title == rhs.title
        }
    }

    @Published public var items: [MenuItem] = []

    @Published public var onboarded: Bool = false

    @Published private var present: Bool = false
    private lazy var presentBinding = Binding(
        get: { [weak self] in
            self?.present ?? false
        },
        set: { [weak self] in
            self?.present = $0
        }
    )

    public init() { }

    public static var previewValue: dydxSimpleUIMarketsHeaderViewModel {
        let vm = dydxSimpleUIMarketsHeaderViewModel()
        vm.items = [
            .init(icon: "icon_copy", title: "Settings", action: {}),
            .init(icon: "icon_copy", title: "Onboarding", action: {})
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let imageName: String
            if dydxThemeSettings.shared.currentThemeType == .light {
                imageName = "dydx_light"
            } else {
                imageName = "dydx"
            }
            let view = HStack(alignment: .center) {
                Image(imageName, bundle: Bundle.dydxView)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 65)

                Spacer()

                let iconName = self.onboarded ? "logo_hedgie" : "hedgie_placeholder"
                let content = PlatformIconViewModel(type: .asset(name: iconName, bundle: .dydxView),
                                                    clip: .circle(background: .layer4, spacing: 4, borderColor: .textTertiary),
                                                    size: CGSize(width: 36, height: 36))
                PlatformButtonViewModel(content: content,
                                        type: .iconType) { [weak self] in
                    withAnimation(Animation.easeInOut) {
                        if !(self?.present ?? false) {
                            self?.present = true
                        }
                    }
                }
                 .createView(parentStyle: style)
                 .popover(present: self.presentBinding, attributes: { attrs in
                     attrs.position = .absolute(
                        originAnchor: .bottom,
                        popoverAnchor: .topLeft
                     )
                     attrs.sourceFrameInset.top = -8
                     let animation = Animation.easeOut(duration: 0.2)
                     attrs.presentation.animation = animation
                     attrs.dismissal.animation = animation
                     attrs.rubberBandingMode = .none
                     attrs.blocksBackgroundTouches = true
                     attrs.onTapOutside = {
                         self.present = false
                     }
                 }, view: {
                     VStack(alignment: .leading, spacing: 0) {
                         ForEach(Array(self.items.enumerated()), id: \.element) { index, item in
                             HStack(spacing: 12) {
                                 PlatformIconViewModel(type: .asset(name: item.icon, bundle: .dydxView),
                                                       size: CGSize(width: 22, height: 22),
                                                       templateColor: .textSecondary)
                                 .createView(parentStyle: style)

                                 Text(item.title)
                                     .themeFont(fontSize: .large)
                                     .themeColor(foreground: .textSecondary)
                             }
                             .themeColor(background: .layer3)
                             .padding(.horizontal, 16)
                             .padding(.vertical, 12)
                             .onTapGesture {
                                 self.present = false
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                     item.action()
                                 })
                             }

                             if index != self.items.count - 1 {
                                 DividerModel().createView(parentStyle: style)
                             }
                         }
                     }
                     .frame(maxWidth: 300)
                     .fixedSize()
                     .themeColor(background: .layer3)
                     .cornerRadius(16, corners: .allCorners)
                     .border(cornerRadius: 16)
                     .environmentObject(ThemeSettings.shared)
                 }, background: {
                     ThemeColor.SemanticColor.layer0.color.opacity(0.7)
                 })

            }
            return AnyView(view)
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketsHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketsHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketsHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketsHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
