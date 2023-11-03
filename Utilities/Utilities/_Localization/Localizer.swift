//
//  Localizer.swift
//  Utilities
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public protocol LocalizerProtocol {
    func localize(_ text: String?) -> String?
}

public class StandardLocalizer: LocalizerProtocol {
    public func localize(_ text: String?) -> String? {
        if let text = text {
            return NSLocalizedString(text, comment: text)
        }
        return nil
    }
}

public class Localizer {
    private static var _shared: LocalizerProtocol?

    public static var shared: LocalizerProtocol? {
        get {
            if _shared == nil {
                _shared = StandardLocalizer()
            }
            return _shared
        }
        set { _shared = newValue }
    }

    public static func localize(_ text: String?) -> String? {
        return shared?.localize(text)
    }
}
