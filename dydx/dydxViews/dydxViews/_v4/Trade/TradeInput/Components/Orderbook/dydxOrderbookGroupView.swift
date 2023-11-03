//
//  dydxOrderbookGroupView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxOrderbookGroupViewModel: PlatformViewModel {
    @Published public var zoom: UInt = 0
    @Published public var price: String?
    public var onZoomed: ((UInt) -> Void)?

    private let maxZoom = 3

    public static var previewValue: dydxOrderbookGroupViewModel = {
        let vm = dydxOrderbookGroupViewModel()
        vm.price = "$0.001"
        vm.zoom = 1
        return vm
    }()

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    Spacer()
                    self.priceLabel.createView(parentStyle: style)
                    self.zoomOutButton.createView(parentStyle: style)
                    self.zoomInButton.createView(parentStyle: style)
                }
                .padding(.vertical, 4)
            )
        }
    }

    var priceLabel: PlatformViewModel {
        if let price = price, price.length > 0 {
            return Text("$\(price)")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smaller)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .wrappedViewModel
        }

        return PlatformView.nilViewModel
    }

    private let buttonSize = 28

    var zoomInButton: PlatformViewModel {
        let buttonContent = PlatformIconViewModel(type: .system(name: "plus"),
                                                  clip: .circle(background: zoom < self.maxZoom ? .layer4 : .layer0,
                                                                spacing: 20,
                                                                borderColor: zoom < self.maxZoom ? ThemeColor.SemanticColor.layer6 : nil),
                                                  size: CGSize(width: buttonSize, height: buttonSize))

        return PlatformButtonViewModel(content: buttonContent, type: .iconType, state: zoom < self.maxZoom ? .primary : .disabled) { [weak self] in
            guard let self = self else {
                return
            }
            if self.zoom < self.maxZoom {
                self.onZoomed?(self.zoom + 1)
            }
        }
    }

    var zoomOutButton: PlatformViewModel {
        let buttonContent = PlatformIconViewModel(type: .system(name: "minus"),
                                                  clip: .circle(background: zoom > 0 ? .layer4 : .layer0,
                                                                spacing: 20,
                                                                borderColor: zoom > 0 ? ThemeColor.SemanticColor.layer6: nil),
                                                  size: CGSize(width: buttonSize, height: buttonSize))
        return PlatformButtonViewModel(content: buttonContent, type: .iconType, state: zoom > 0 ? .primary : .disabled) { [weak self] in
            guard let self = self else {
                return
            }
            if self.zoom > 0 {
                self.onZoomed?(self.zoom - 1)
            }
        }
    }
}

#if DEBUG
    struct dydxOrderbookGroupViewModel_Previews_Dark: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyDarkTheme()
            ThemeSettings.applyStyles()
            return dydxOrderbookGroupViewModel.previewValue
                .createView()
                // .edgesIgnoringSafeArea(.bottom)
                .previewLayout(.sizeThatFits)
        }
    }

    struct dydxOrderbookGroupViewModel_Previews_Light: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyLightTheme()
            ThemeSettings.applyStyles()
            return dydxOrderbookGroupViewModel.previewValue
                .createView()
                // .edgesIgnoringSafeArea(.bottom)
                .previewLayout(.sizeThatFits)
        }
    }
#endif
