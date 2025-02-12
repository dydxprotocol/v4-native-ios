//
//  PlatformPopoverOptionsInput.swift
//  PlatformUI
//
//  Created by Rui Huang on 13/02/2025.
//

import SwiftUI
import Utilities
import Introspect
import Popovers

open class PlatformPopoverOptionsInputViewModel: PlatformOptionsInputViewModel {
    @Published public var position = Popover.Attributes.Position.absolute(
        originAnchor: .topRight,
        popoverAnchor: .bottomRight
    )

    @Published private var present: Bool = false

    private lazy var presentBinding = Binding(
        get: { [weak self] in
            self?.present ?? false
        },
        set: { [weak self] in
            self?.present = $0
        }
    )

    override open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            guard let titles = self.optionTitles else {
                return AnyView(PlatformView.nilView)
            }

            return AnyView(
                Button(action: {  [weak self] in
                    if !(self?.present ?? false) {
                        self?.present = true
                    }
                }, label: {
                    VStack(alignment: .leading, spacing: 4) {
                        self.header.createView(parentStyle: style)
                        self.selectedItemView
                            .createView(parentStyle: style)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                })
                .popover(present: self.presentBinding, attributes: { [weak self] attrs in
                    guard let self = self else {
                        return
                    }
                    attrs.position = self.position
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
                        ForEach(Array(titles.enumerated()), id: \.element) { index, title in
                            Button(action: {
                                if index != self.index {
                                    self.index = index
                                    self.onEdited?(self.options?[index].value)
                                }
                                self.present = false
                            }) {
                                HStack {
                                    Text(title)
                                        .themeFont(fontSize: .medium)
                                        .themeColor(foreground: .textPrimary)
                                    Spacer()
                                    if index == self.index {
                                        PlatformIconViewModel(type: .system(name: "checkmark"), size: CGSize(width: 16, height: 16))
                                            .createView(parentStyle: parentStyle, styleKey: styleKey)
                                    }
                                }
                                .contentShape(Rectangle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            let isLast = index == titles.count - 1
                            if !isLast {
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

            )
        }
    }

    open var selectedItemView: PlatformViewModel {
        let index = index ?? 0
        if let titles = optionTitles, index < titles.count {
            let selectedText = titles[index]
            return Text(selectedText)
                    .themeFont(fontSize: .medium)
                    .leftAligned()
                    .wrappedViewModel
        }
        return PlatformView.nilViewModel
    }
}
