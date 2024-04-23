//
//  dydxReceiptView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxReceiptViewModel: PlatformViewModel {
    @Published public var children: [PlatformViewModel]? {
        didSet {
            updateCollapsed()
        }
    }
    public let maxCollapsedItems: Int = 4

    @Published private var collapsed: Bool = true

    public init() { }

    public static var previewValue: dydxReceiptViewModel {
        let vm = dydxReceiptViewModel()
        vm.children = [
            dydxReceiptBuyingPowerViewModel.previewValue,
            dydxReceiptMarginUsageViewModel.previewValue,
            dydxReceiptFeeViewModel.previewValue,
            dydxReceiptItemViewModel.previewValue
        ]
        return vm
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let children = self.children ?? []
            let items = self.collapsed ? Array(children.prefix(self.maxCollapsedItems - 1)) : children

            let content = VStack(alignment: .leading) {
                ForEach(items, id: \.self.id) { child in
                    child.createView(parentStyle: style)
                        .frame(height: 18)
                }
                Spacer().frame(maxHeight: 16)
                if children.count > self.maxCollapsedItems {
                    self.createCollapseButton(parentStyle: style)
                }
            }
            return AnyView(
                content
                    .animation(.default, value: UUID())
            )
        }
    }

    private func createCollapseButton(parentStyle: ThemeStyle) -> some View {
        let buttonText = self.collapsed ? DataLocalizer.localize(path: "APP.GENERAL.SHOW_ALL_DETAILS") : DataLocalizer.localize(path: "APP.GENERAL.HIDE_ALL_DETAILS")
        let content = HStack {
            Text(buttonText)
                .themeFont(fontType: .base, fontSize: .small)
                .themeColor(foreground: .textTertiary)
            Spacer()
            let imageName = self.collapsed ? "chevron.down": "chevron.up"
            PlatformIconViewModel(type: .system(name: imageName),
                                  size: CGSize(width: 10, height: 10))
            .createView(parentStyle: parentStyle)
        }
            .padding(.horizontal, -8)
            .padding(.vertical, -4)

        return Button(action: { [weak self] in
            withAnimation {
                self?.collapsed.toggle()
            }
        }) {
            content
        }
        .buttonStyle(BorderlessButtonStyle())
        .frame(maxWidth: .infinity)
        .padding()
        .themeColor(background: .layer3)
        .borderAndClip(style: .cornerRadius(12), borderColor: .borderDefault, lineWidth: 1)
        .padding(.horizontal, -8)
    }

    private func updateCollapsed() {
        collapsed = (children?.count ?? 0) > maxCollapsedItems
    }
}

#if DEBUG
struct dydxTradeReceiptView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeReceiptView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxReceiptViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
