//
//  String+Localized.swift
//  Utilities
//
//  Created by Qiang Huang on 4/30/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public extension String {
    var localized: String {
        return localized(in: nil)
    }

    func localized(in bundle: Bundle?) -> String {
        if let bundle = bundle {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: self, comment: "")
        } else {
            let bundles = Bundle.particles
            var localized: String = ""
            for bundle in bundles {
                localized = NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
                if localized != "" {
                    break
                }
            }
            LocalizerBuffer.shared?.localize(self, to: localized)
            return localized != "" ? localized : self
        }
    }
}
