//
//  dydxMarketsMenuItem.swift
//  dydxViews
//
//  Created by Rui Huang on 10/06/2025.
//

import Foundation

public struct dydxMarketsMenuItem: Hashable, Equatable {
    public init(icon: String, title: String, subtitle: String? = nil, selected: Bool, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.selected = selected
        self.action = action
    }

    public var icon: String
    public var title: String
    public var subtitle: String?
    public var selected: Bool
    public var action: () -> Void

    public func hash(into hasher: inout Hasher) {
        hasher.combine(icon)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(selected)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.icon == rhs.icon &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.selected == rhs.selected
    }
}
