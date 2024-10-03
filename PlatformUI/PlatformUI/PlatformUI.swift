//
//  PlatformUI.swift
//  PlatformUI
//
//  Created by Rui Huang on 8/22/22.
//

import SwiftUI

public protocol PlatformUIViewProtocol {
    var themeSettings: ThemeSettings { get }
    var parentStyle: ThemeStyle { get }
    var styleKey: String? { get }
}

public extension PlatformUIViewProtocol {

    var style: ThemeStyle {
        guard let styleKey = styleKey else {
            return parentStyle
        }

        if let itemStyle = themeSettings.styleConfig.styles[styleKey] {
            return parentStyle.merge(from: itemStyle)
        }

        assertionFailure("StyleKey not found: \(styleKey)")
        return parentStyle
    }
}

public enum PlatformUISign {
    case plus
    case minus
    case none

    public init(value: Double?) {
        if value ?? 0 > 0 {
            self = .plus
        } else if value ?? 0 < 0 {
            self = .minus
        } else {
            self = .none
        }
    }
}
