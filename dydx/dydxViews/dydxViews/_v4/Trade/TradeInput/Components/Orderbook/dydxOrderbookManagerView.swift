//
//  dydxOrderbookManagerView.swift
//  dydxViews
//
//  Created by Michael Maguire on 7/12/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxOrderbookManagerViewModel: PlatformViewModel {
    var isOrderbookCollapsedChanged: ((Bool) -> Void)?

    @Published var isOrderbookCollapsed: Bool = false
    @Published public var group: dydxOrderbookGroupViewModel? = dydxOrderbookGroupViewModel()

    public static var previewValue: dydxOrderbookManagerViewModel = {
        let vm = dydxOrderbookManagerViewModel()
        vm.isOrderbookCollapsed = false
        vm.group = .previewValue
        return vm
    }()

    private var iconName: String { isOrderbookCollapsed ? "chevron.right" : "chevron.left" }

    private func toggleVisibility() {
        withAnimation(.linear(duration: 0.1)) {
            isOrderbookCollapsed.toggle()
        }
        isOrderbookCollapsedChanged?(isOrderbookCollapsed)
    }

    private let optionHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 12
    private let optionPadding: CGFloat = 3

    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return AnyView(
                HStack(spacing: 0) {
                    Button(action: self.toggleVisibility) {
                        HStack {
                            Spacer()
                            if self.isOrderbookCollapsed {
                                Text(DataLocalizer.localize(path: "APP.TRADE.ORDERBOOK"))
                            }
                            PlatformIconViewModel(type: .system(name: self.iconName), size: .init(width: 8, height: 14))
                                .createView(parentStyle: style)
                            Spacer()
                        }
                        .frame(maxWidth: self.isOrderbookCollapsed ? .infinity : self.optionHeight)
                        .frame(height: self.optionHeight)
                        .themeFont(fontSize: .medium)
                        .themeColor(foreground: .textTertiary)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: self.cornerRadius)
                            .stroke(ThemeColor.SemanticColor.textTertiary.color, lineWidth: 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius))
                    .padding(.vertical, self.optionPadding)

                    if self.isOrderbookCollapsed == false {
                        self.group?
                            .createView(parentStyle: style)
                    }
                }
                    .frame(height: 52)
            )
        }
    }

}

#if DEBUG
struct dydxOrderbookManagerViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputSideViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxOrderbookManagerViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputSideViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
