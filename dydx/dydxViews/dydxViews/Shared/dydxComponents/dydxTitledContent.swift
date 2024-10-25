//
//  dydxTitledContent.swift
//  dydxViews
//
//  Created by Michael Maguire on 10/25/24.
//

import SwiftUI

struct dydxTitledContent<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    @ViewBuilder
    private var titleView: some View {
        Text(title)
            .themeColor(foreground: .textTertiary)
            .themeFont(fontType: .base, fontSize: .smaller)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            titleView
            content
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .makeInput()
    }
}
