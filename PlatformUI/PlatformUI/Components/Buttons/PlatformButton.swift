//
//  PlatformButton.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/26/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI

public enum PlatformButtonState {
    case primary, secondary, disabled, destructive
}

public enum PlatformButtonType {
    case defaultType(fillWidth: Bool = true,
                     pilledCorner: Bool = false,
                     padding: EdgeInsets = .init(all: 14)),
         iconType,
         pill,
         small
}

public class PlatformButtonViewModel<Content: PlatformViewModeling>: PlatformViewModel {
    @Published public var action: () -> Void
    @Published public var content: Content
    @Published public var type: PlatformButtonType
    @Published public var state: PlatformButtonState

    public init(content: Content,
                type: PlatformButtonType = .defaultType(),
                state: PlatformButtonState = .primary,
                action: @escaping () -> Void) {
        self.content = content
        self.type = type
        self.state = state
        self.action = action
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let disabled = .disabled == self.state
            return AnyView(
                Group {
                    switch self.type {
                    case .defaultType(let fillWidth, let pilledCorner, let padding):
                       let button = Button(action: self.action) {
                            HStack {
                                if fillWidth {
                                    Spacer()
                                }
                                self.content
                                    .createView(parentStyle: style.themeFont(fontType: .plus), styleKey: self.buttonStyleKey)
                                if fillWidth {
                                    Spacer()
                                }
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(disabled)
                        .padding(padding)
                        .if(fillWidth) { view in
                            view.frame(maxWidth: .infinity)
                        }
                        .themeStyle(styleKey: self.buttonStyleKey, parentStyle: style)
                        .if(pilledCorner) { view in
                            view.clipShape(Capsule())
                        }
                        .if(!pilledCorner) { view in
                            view.cornerRadius(8)
                        }

                        let borderWidth: CGFloat = 1
                        let cornerRadius: CGFloat = 8
                        switch self.state {
                        case .primary:
                            button
                                // adding invisible border ensures different states have equal heights/widths,
                                // otherwise, no border buttons are slightly shorter than border buttons
                                .border(borderWidth: borderWidth, cornerRadius: cornerRadius, borderColor: ThemeColor.SemanticColor.transparent.color)
                        case .destructive:
                            button
                                .border(borderWidth: borderWidth, cornerRadius: cornerRadius, borderColor: ThemeColor.SemanticColor.colorFadedRed.color)
                        case .secondary:
                            button
                                .border(borderWidth: borderWidth, cornerRadius: cornerRadius, borderColor: ThemeColor.SemanticColor.layer7.color)
                        case .disabled:
                            button
                                .border(borderWidth: borderWidth, cornerRadius: cornerRadius, borderColor: ThemeColor.SemanticColor.layer6.color)
                        }

                    case .small:
                        Button(action: self.action) {
                                self.content
                                    .createView(parentStyle: style, styleKey: self.buttonStyleKey)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(disabled)
                        .padding(9)
                        .themeStyle(styleKey: self.buttonStyleKey, parentStyle: style)
                        .cornerRadius(6)

                    case .iconType:
                        Button(action: self.action) {
                            self.content.createView(parentStyle: style, styleKey: nil)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(disabled)

                    case .pill:
                        Button(action: self.action) {
                            self.content.createView(parentStyle: style, styleKey: nil)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(disabled)
                        .padding([.bottom, .top], 4)
                        .padding([.leading, .trailing], 12)
                        .themeStyle(styleKey: self.buttonStyleKey, parentStyle: style)
                        .clipShape(Capsule())
                    }
                }
            )
        }
    }

    private var buttonStyleKey: String {
        switch state {
        case .primary:
            return "button-primary"
        case .secondary:
            return "button-secondary"
        case .disabled:
            return "button-disabled"
        case .destructive:
            return "button-destructive"
        }
    }
}

#if DEBUG
struct PlatformButton_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            PlatformButtonViewModel(content: PlatformViewModel { _ in AnyView(Text("Primary")) },
                                    state: .primary) {}
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformButtonViewModel(content: PlatformViewModel { _ in AnyView(Text("Secondary")) },
                                    state: .secondary) {}
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformButtonViewModel(content: PlatformViewModel { _ in AnyView(Text("Disabled")) },
                                    state: .disabled) {}
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformButtonViewModel(content: PlatformViewModel { _ in AnyView(Text("Destructive")) },
                                    state: .destructive) {}
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformButtonViewModel(content: PlatformIconViewModel(type: .system(name: "heart.fill"),
                                                 clip: .circle(background: .layer3, spacing: 15)),
                                    type: .iconType) {}
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformButtonViewModel(content: PlatformViewModel { _ in AnyView(Text("Pill")) },
                                    type: .pill,
                                    state: .secondary) {}
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformButtonViewModel(content: PlatformIconViewModel(type: .system(name: "heart.fill")),
                                    type: .pill) {}
                .createView()
                .previewLayout(.sizeThatFits)

            PlatformButtonViewModel(content: PlatformViewModel { _ in AnyView(Text("Smaller")) },
                                    type: .small) {}
                .createView()
                .previewLayout(.sizeThatFits)

        }
    }
}
#endif
