//
//  dydxCheckboxView.swift
//  dydxViews
//
//  Created by Michael Maguire on 9/9/24.
//

import SwiftUI
import PlatformUI

/// Checkbox with some text next to it
struct dydxCheckboxView: View {
    @Binding var isChecked: Bool
    private var attributedText: AttributedString

    init(isChecked: Binding<Bool>, text: String) {
        let attributedText = AttributedString(text)
        self.init(isChecked: isChecked, attributedText: attributedText)
    }

    init(isChecked: Binding<Bool>, attributedText: AttributedString) {
        self._isChecked = isChecked
        self.attributedText = attributedText
            .themeFont(fontSize: .medium)
            .themeColor(foreground: .textSecondary)
    }

    var body: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .center) {
                ThemeColor.SemanticColor.layer0.color
                PlatformIconViewModel(type: .asset(name: "icon_checked", bundle: .dydxView),
                                      clip: .noClip,
                                      size: .init(width: 15, height: 15),
                                      templateColor: .textPrimary)
                    .createView()
                    .opacity(isChecked ? 1 : 0)
            }
            .frame(width: 20, height: 20)
            .borderAndClip(style: .cornerRadius(6), borderColor: .borderDefault)
            Text(attributedText)
        }
        .leftAligned()
        .onTapGesture {
            isChecked.toggle()
        }
    }
}
