//
//  PlatformViewModel.swift
//  PlatformUI
//
//  Created by Rui Huang on 9/1/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import Utilities
import Combine

public protocol PlatformViewModeling: ObservableObject, Identifiable {
    associatedtype Content: View

    func createView(parentStyle: ThemeStyle, styleKey: String?) -> Content
}

open class PlatformViewModel: PlatformViewModeling {
    private let bodyBuilder: ((_ style: ThemeStyle) -> AnyView)?

    public init(bodyBuilder: ((_ style: ThemeStyle) -> AnyView)? = nil) {
        self.bodyBuilder = bodyBuilder
    }

    open func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        return PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            if let bodyBuilder = self?.bodyBuilder {
                return AnyView(bodyBuilder(style))
            } else {
                return AnyView(Text(""))
            }
        }
    }

    public func updateView() {
        self.objectWillChange.send()
    }
}

public struct PlatformView: View, PlatformUIViewProtocol {
    public static let nilView: Text? = nil
    public static let nilViewModel = PlatformViewModel() { _ in AnyView(nilView) }
    public static let emptyView = Text("")

    private var bodyBuilder: ((_ style: ThemeStyle) -> AnyView)?

    public init(viewModel: PlatformViewModel = PlatformViewModel(),
                parentStyle: ThemeStyle = ThemeStyle.defaultStyle,
                styleKey: String? = nil,
                bodyBuilder: @escaping ((_ style: ThemeStyle) -> AnyView)) {
        self.viewModel = viewModel
        self.parentStyle = parentStyle
        self.styleKey = styleKey
        self.bodyBuilder = bodyBuilder
    }

    @ObservedObject public var viewModel: PlatformViewModel

    // System-wide theme settings.  Do not change this.
    @ObservedObject public var themeSettings = ThemeSettings.shared

    // Pass this to child views
    public var parentStyle: ThemeStyle = ThemeStyle.defaultStyle

    // Update this to provide custom style key if necessary
    public var styleKey: String?

    public var body: some View {
        Group {
            bodyBuilder?(style)
        }
        .themeStyle(style: style)
        .environmentObject(themeSettings)
    }
}

public extension View {
    var wrappedViewModel: PlatformViewModel {
        PlatformViewModel() { _ in
            AnyView(self)
        }
    }
}
