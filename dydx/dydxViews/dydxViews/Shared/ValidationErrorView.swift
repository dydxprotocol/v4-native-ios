//
//  ValidationErrorView.swift
//  dydxUI
//
//  Created by Rui Huang on 02/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class ValidationErrorViewModel: PlatformViewModel {
    public enum State {
        case error, warning, none

        var color: ThemeColor.SemanticColor {
            switch self {
            case .error: return .colorRed
            case .warning: return .colorYellow
            case .none: return .layer2
            }
        }
        var backgroundColor: ThemeColor.SemanticColor {
            switch self {
            case .error: return .colorFadedRed
            case .warning: return .colorFadedYellow
            case .none: return .layer2
            }
        }
    }

    public struct Link {
        public var text: String
        public var action: () -> Void

        public init(text: String, action: @escaping () -> Void) {
            self.text = text
            self.action = action
        }
    }

    @Published public var state = State.none
    @Published public var link: Link?
    @Published public var title: String?
    @Published public var message: String?

    public static var previewValue: ValidationErrorViewModel = {
        let vm = ValidationErrorViewModel()
        vm.state = .error
        vm.link = .init(text: "link test", action: {})
        vm.title = "title test"
        vm.message = "message test"
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self, self.state != .none else { return AnyView(PlatformView.nilView) }

            let view = HStack(spacing: 0) {
                Rectangle()
                    .fill(self.state.color.color)
                    .frame(width: 6)

                VStack(alignment: .leading, spacing: 8) {
                    if let title = self.title {
                        Text(title)
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontSize: .small)
                    }
                    if let message = self.message {
                        Text(message)
                            .themeFont(fontSize: .small)
                    }
                    if let link = self.link {
                        Text(link.text)
                            .themeColor(foreground: .textPrimary)
                            .themeFont(fontSize: .small)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                Spacer()
            }
                .themeColor(background: self.state.backgroundColor)
                .clipShape(.rect(cornerRadius: 6))

            return AnyView(view)
        }
    }
}

#if DEBUG
struct ValidationErrorViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return ValidationErrorViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct ValidationErrorViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return ValidationErrorViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

#endif
