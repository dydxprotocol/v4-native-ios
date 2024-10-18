//
//  PlatformUI+Ext.swift
//  dydxViews
//
//  Created by Michael Maguire on 10/1/24.
//

import PlatformUI
import SwiftUI

public extension PlatformIconViewModel.IconType {

    init(url: URL?, placeholderText: String?) {
        self = .url(url: url, placeholderContent: { Text(placeholderText ?? "")
            .frame(width: 32, height: 32)
            .themeColor(foreground: .textTertiary)
            .themeColor(background: .layer5)
            .borderAndClip(style: .circle, borderColor: .layer7, lineWidth: 1)
            .wrappedInAnyView()
        })
    }
}
