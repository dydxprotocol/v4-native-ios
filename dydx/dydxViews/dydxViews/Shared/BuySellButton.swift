//
//  BuySellButton.swift
//  dydxUI
//
//  Created by Rui Huang on 9/26/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class BuySellButtonModel: BuySellViewModel {
    @Published public var tapAction: (() -> Void)?

    public init(text: String = "", color: ThemeColor.SemanticColor = ThemeSettings.positiveColor, tapAction: (() -> Void)?) {
        super.init(text: text, color: color)
        self.tapAction = tapAction
    }

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        let view = super.createView(parentStyle: parentStyle, styleKey: styleKey)
        return PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            return AnyView(
                view
                .onTapGesture {
                    self?.tapAction?()
                }
             )
        }
    }
}

public class BuySellViewModel: PlatformViewModel {
    public enum ButtonType {
        case primary, secondary

        internal var borderWidth: CGFloat {
            switch self {
            case .primary:
                return 2
            case .secondary:
                return 1
            }
        }
    }

    private let optionHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 12
    private let optionPadding: CGFloat = 3

    @Published public var text: String = ""
    @Published public var color: ThemeColor.SemanticColor = ThemeSettings.positiveColor
    @Published public var buttonType = ButtonType.primary

    public init() { }

    public init(text: String = "", color: ThemeColor.SemanticColor = ThemeSettings.positiveColor, buttonType: ButtonType = .primary) {
        self.text = text
        self.color = color
        self.buttonType = buttonType
    }

    public static var previewValue: BuySellViewModel {
        let vm = BuySellViewModel()
        vm.text = "Sell"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                Text(text)
                    .themeFont(fontSize: .medium)
                    .foregroundColor(color.color)
                    .frame(height: optionHeight)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(color.color, lineWidth: self.buttonType.borderWidth)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .padding(optionPadding)
            )
        }
    }
}

#if DEBUG
struct BuySellButton_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return BuySellButtonModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct BuySellButton_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return BuySellButtonModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
