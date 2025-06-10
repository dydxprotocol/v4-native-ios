//
//  dydxSimpleUIPositionsToggleView.swift
//  dydxUI
//
//  Created by Rui Huang on 10/06/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUIPositionsToggleViewModel: PlatformViewModel {
    @Published public var items: [dydxMarketsMenuItem] = []

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

    public static var previewValue: dydxSimpleUIPositionsToggleViewModel {
        let vm = dydxSimpleUIPositionsToggleViewModel()
        vm.items = [
            .init(icon: "icon_copy", title: "Settings", subtitle: nil, selected: true, action: {}),
            .init(icon: "icon_copy", title: "Onboarding", subtitle: "subtitle", selected: false, action: {})
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let selected = items.first { $0.selected}

            let view = Button { [weak self] in
                self?.present.toggle()
            } label: {
                HStack {
                    Text(selected?.title ?? "")
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .smaller)

                    PlatformIconViewModel(type: .asset(name: "icon_toggle", bundle: Bundle.dydxView),
                                          clip: .circle(background: .layer4, spacing: 9, borderColor: nil),
                                          size: CGSize(width: 25, height: 25),
                                          templateColor: .textTertiary)
                    .createView(parentStyle: style)
                }
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
                        Text(DataLocalizer.localize(path: "APP.GENERAL.VIEW"))
                            .themeColor(foreground: .textTertiary)
                            .themeFont(fontSize: .small)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)

                        DividerModel().createView(parentStyle: parentStyle)

                        ForEach(Array(self.items.enumerated()), id: \.element) { index, item in
                            self.createItemView(item: item, parentStyle: style)

                            if index != self.items.count - 1 {
                                DividerModel().createView(parentStyle: parentStyle)
                            }
                        }
                    }
                    .frame(minWidth: 200)
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

    private func createItemView(item: dydxMarketsMenuItem, parentStyle: ThemeStyle) -> some View {
        HStack {
            Text(item.title)
                .themeColor(foreground: item.selected ? .textTertiary : .textPrimary)
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .themeColor(foreground: .textTertiary)
            }
            Spacer()
            PlatformIconViewModel(type: .asset(name: item.icon, bundle: .dydxView),
                                  size: CGSize(width: 22, height: 22),
                                  templateColor: item.selected ? .textTertiary : .textSecondary)
            .createView(parentStyle: parentStyle)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .themeColor(background: item.selected ? .layer0 : .layer3)
        .onTapGesture {
            self.present = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                item.action()
            })
        }
    }
}

#if DEBUG
struct dydxSimpleUIPortfolioToggleView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIPositionsToggleViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIPortfolioToggleView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIPositionsToggleViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
