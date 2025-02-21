//
//  CollectionItemUtil.swift
//  dydxViews
//
//  Created by Rui Huang on 16/01/2025.
//

import SwiftUI
import PlatformUI
import Utilities

struct CollectionItemUtil {
    static func createCollectionItem(parentStyle: ThemeStyle, title: String?, valueViewModel: PlatformViewModel?) -> some View {
        let titleViewModel = Text(title ?? "")
            .themeFont(fontType: .plus, fontSize: .small)
            .themeColor(foreground: .textTertiary)
            .wrappedViewModel
        return createCollectionItem(parentStyle: parentStyle, titleViewModel: titleViewModel, valueViewModel: valueViewModel)
    }

    static func createCollectionItem(parentStyle: ThemeStyle, titleViewModel: PlatformViewModel?, value: String?) -> some View {
        let valueViewModel = Text(value ?? "-")
            .themeFont(fontSize: .large)
            .themeColor(foreground: .textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
           // .fixedSize(horizontal: true, vertical: false)
            .leftAligned()
            .wrappedViewModel
        return createCollectionItem(parentStyle: parentStyle, titleViewModel: titleViewModel, valueViewModel: valueViewModel)
    }

    static func createCollectionItem(parentStyle: ThemeStyle, title: String?, value: String?) -> some View {
        let titleViewModel = Text(title ?? "")
            .themeFont(fontType: .plus, fontSize: .small)
            .themeColor(foreground: .textTertiary)
            .wrappedViewModel
        let valueViewModel = Text(value ?? "-")
            .themeFont(fontSize: .large)
            .themeColor(foreground: .textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
          //  .fixedSize(horizontal: true, vertical: false)
            .leftAligned()
            .wrappedViewModel
        return createCollectionItem(parentStyle: parentStyle, titleViewModel: titleViewModel, valueViewModel: valueViewModel)
    }

    static func createCollectionItem(parentStyle: ThemeStyle, titleViewModel: PlatformViewModel?, valueViewModel: PlatformViewModel?) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                titleViewModel?.createView(parentStyle: parentStyle)
                    .lineLimit(1)

                if let valueViewModel {
                    valueViewModel.createView(parentStyle: parentStyle, styleKey: nil)
                } else {
                    Text( "-")
                        .themeFont(fontSize: .large)
                        .themeColor(foreground: .textSecondary)
                        .lineLimit(1)
                        .leftAligned()
                }
            }
            Spacer()
        }
        .leftAligned()
    }
}
