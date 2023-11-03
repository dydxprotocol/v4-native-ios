//
//  UINib+Safeload.swift
//  Utilities
//
//  Created by Qiang Huang on 4/30/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

extension UINib {
    @objc public static func safeLoad(xib: String, bundles: [Bundle]) -> UINib? {
        var nib: UINib?
        for bundle in bundles {
            nib = safeLoad(xib: xib, bundle: bundle)
            if nib != nil {
                break
            }
        }
        return nib
    }

    @objc public static func safeLoad(xib: String, bundle: Bundle) -> UINib? {
        let file = bundle.path(forResource: xib, ofType: "nib")
        if File.exists(file) {
            return UINib(nibName: xib, bundle: bundle)
        }
        return nil
    }
}
