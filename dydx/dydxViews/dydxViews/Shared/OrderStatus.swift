//
//  OrderStatus.swift
//  dydxUI
//
//  Created by Rui Huang on 5/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class OrderStatusModel: PlatformViewModel {
    public enum Status {
        case red, green, yellow, blank

        var color: Color? {
            switch self {
            case .red:
                return ThemeSettings.negativeColor.color
            case .green:
                return ThemeSettings.positiveColor.color
            case .blank:
                return ThemeColor.SemanticColor.textPrimary.color
            case .yellow:
                return ThemeColor.SemanticColor.colorYellow.color
            }
        }
    }
    @Published public var status: Status?

    public init(status: OrderStatusModel.Status? = nil) {
        self.status = status
    }

    public static var previewValue: OrderStatusModel {
        let vm = OrderStatusModel()
        vm.status = .blank
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                ZStack {
                    Circle()
                        .fill(ThemeColor.SemanticColor.layer0.color ?? .clear)
                        .frame(width: 16, height: 16)
                    Circle()
                        .fill(self.status?.color ?? .clear)
                        .frame(width: 12, height: 12)
                }
            )
        }
    }
}

#if DEBUG
struct OrderStatus_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return OrderStatusModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct OrderStatus_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return OrderStatusModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
