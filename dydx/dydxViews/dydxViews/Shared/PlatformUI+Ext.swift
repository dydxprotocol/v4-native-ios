//
//  PlatformUI+Ext.swift
//  dydxViews
//
//  Created by Michael Maguire on 10/1/24.
//

import PlatformUI
import SwiftUI

extension PlatformIconViewModel {
    /// creates a PlatformIconViewModel with a URL and placeholder Text element if the URL is unavailable
    public convenience init(url: URL?, placeholderText: String?) {
        if let placeholderText {
            let placeholderContent = { Text(placeholderText)
                    .frame(width: 32, height: 32)
                    .themeColor(foreground: .textTertiary)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .circle, borderColor: .layer7, lineWidth: 1)
                    .wrappedInAnyView()
            }
            self.init(type: .url(url: url, placeholderContent: placeholderContent))
        } else {
            self.init(type: .url(url: url, placeholderContent: nil))
        }
    }
}
