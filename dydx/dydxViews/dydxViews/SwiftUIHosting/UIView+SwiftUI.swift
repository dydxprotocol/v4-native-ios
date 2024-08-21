//
//  UIView+SwiftUI.swift
//  dydxViews
//
//  Created by Rui Huang on 10/5/22.
//

import SwiftUI
import UIKit

public extension UIView {
    var swiftUIView: some View {
        SwiftUIViewWrapper(uiView: self)
    }
}

private struct SwiftUIViewWrapper<V: UIView>: UIViewRepresentable {
    private let uiView: V

    init(uiView: V) {
        self.uiView = uiView
    }

    func makeUIView(context: Context) -> V {
        uiView
    }

    func updateUIView(_ uiView: V, context: Context) {
    }
}
