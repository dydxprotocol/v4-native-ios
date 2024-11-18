//
//  dydxOrderbookView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public enum OrderbookDisplay {
    case all
    case asks
    case bids
}

public class dydxOrderbookViewModel: PlatformViewModel {
    @Published public var asks: dydxOrderbookAsksViewModel? = dydxOrderbookAsksViewModel()
    @Published public var bids: dydxOrderbookBidsViewModel? = dydxOrderbookBidsViewModel()
    @Published public var spread: dydxOrderbookSpreadViewModel? = dydxOrderbookSpreadViewModel()
    public var delegate: dydxOrderbookSideDelegate? {
        get {
            return asks?.delegate ?? bids?.delegate
        }
        set {
            asks?.delegate = newValue
            bids?.delegate = newValue
        }
    }

    public static var previewValue: dydxOrderbookViewModel {
        let vm = dydxOrderbookViewModel()
        return vm
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(spacing: 0) {
                    self.orderbookRows(style: style, asks: self.asks, bids: self.bids)
                        .frame(maxHeight: .infinity)
                }
            )
        }
    }

    private func orderbookRows(style: ThemeStyle, asks: dydxOrderbookSideViewModel?, bids: dydxOrderbookSideViewModel?) -> some View {
        GeometryReader { [weak self] metrics in
            let spacing = 8.0
            let spreadViewHeight = 16.0
            let numViews = 3.0
            let totalSpacingHeight = spacing * (numViews - 1)
            VStack(spacing: spacing) {
                if let asks = asks {
                    if let bids = bids {
                        let barAreaHeight = (metrics.size.height - spreadViewHeight - totalSpacingHeight) / 2.0

                        asks.createView(parentStyle: style)
                            .frame(height: barAreaHeight)

                        self?.spread?.createView(parentStyle: style)
                            .frame(height: spreadViewHeight)

                        bids.createView(parentStyle: style)
                            .frame(height: barAreaHeight)

                    } else {
                        asks.createView(parentStyle: style)
                            .frame(maxHeight: .infinity)

                        self?.spread?.createView(parentStyle: style)
                    }
                } else {
                    if let bids = bids {
                        bids.createView(parentStyle: style)
                            .frame(maxHeight: .infinity)

                        self?.spread?.createView(parentStyle: style)

                    } else {
                        Text("")
                    }
                }
            }
        }
    }
}

#if DEBUG
    struct dydxOrderbookViewModel_Previews_Dark: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyDarkTheme()
            ThemeSettings.applyStyles()
            return dydxOrderbookViewModel.previewValue
                .createView()
                // .edgesIgnoringSafeArea(.bottom)
                .previewLayout(.sizeThatFits)
        }
    }

    struct dydxOrderbookViewModel_Previews_Light: PreviewProvider {
        @StateObject static var themeSettings = ThemeSettings.shared

        static var previews: some View {
            ThemeSettings.applyLightTheme()
            ThemeSettings.applyStyles()
            return dydxOrderbookViewModel.previewValue
                .createView()
                // .edgesIgnoringSafeArea(.bottom)
                .previewLayout(.sizeThatFits)
        }
    }
#endif
