//
//  RadioButtonGroup.swift
//  dydxViews
//
//  Created by Michael Maguire on 8/5/24.
//

import Foundation
import SwiftUI
import PlatformUI

protocol RadioButtonContentDisplayable: Equatable {
    var displayText: String { get }
}

/// A simplified version of TabGroup which supports binding for the selected option and does not require a view builder for each item.
/// Use TabGroup when the radio buttons are not displaying exclusively Text.
struct RadioButtonGroup<ButtonItem: RadioButtonContentDisplayable>: View {
    
    @Binding var selected: ButtonItem

    let options: [ButtonItem]

    let buttonClipStyle: ClipStyle
    /// when not specified, width will be natural. When specified, width will be forced
    let itemWidth: CGFloat?
    /// when not specified, height will be natural. When specified, height will be forced
    let itemHeight: CGFloat?

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<options.count, id: \.self) { index in
                let option = options[index]
                RadioButton(displayText: option.displayText,
                            isSelected: selected == option,
                            clipStyle: buttonClipStyle,
                            width: itemWidth,
                            height: itemHeight
                ) {
                    selected = option
                }
            }
        }
    }
}

struct RadioButton: View {
    let displayText: String
    let isSelected: Bool
    let clipStyle: ClipStyle
    let width: CGFloat?
    let height: CGFloat?
    let selectionAction: () -> Void

    private var verticalSpacer: some View {
        Spacer(minLength: 11)
    }
    
    private var horizontalSpacer: some View {
        Spacer(minLength: 8)
    }
    
    var body: some View {
        Text(displayText)
            .lineLimit(1)
            .themeColor(foreground: isSelected ? .textPrimary : .textTertiary)
            .themeFont(fontType: .base, fontSize: .smaller)
            // if width is specified, i.e. non-nil, setting horizontal inset to 0 will allow entire space to be used horizontally
            .padding(.horizontal, width == nil ? 8 : 0)
            // if height is specified, i.e. non-nil, setting vertical inset to 0 will allow entire space to be used horizontally
            .padding(.horizontal, width == nil ? 8 : 0)
            .centerAligned()
            .frame(width: width, height: height)
            .fixedSize()
            .themeColor(background: isSelected ? .layer1 : .layer3)
            .borderAndClip(style: clipStyle, borderColor: .borderDefault)
            .onTapGesture {
                selectionAction()
            }
    }
}
