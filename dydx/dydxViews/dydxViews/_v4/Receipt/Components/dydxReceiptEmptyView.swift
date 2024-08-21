//
//  dydxReceiptEmptyView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/20/23.
//

import SwiftUI
import PlatformUI

struct dydxReceiptEmptyView {
    static var emptyValue: some View {
        Text("-")
            .themeColor(foreground: .textTertiary)
            .themeFont(fontType: .number, fontSize: .small)
    }
}
