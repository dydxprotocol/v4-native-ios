//
//  XibLoader.swift
//  Utilities
//
//  Created by John Huang on 1/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public class XibLoader {
    internal static var cache: [String: UINib] = [:]

    public static func load<T: NSObject>(from nib: String?) -> T? {
        if let nib = nib {
            Console.shared.log("Loading XIB: \(nib)")
            var uiNib = cache[nib]
            if uiNib == nil {
                let bundles = Bundle.particles
                for bundle in bundles {
                    uiNib = UINib.safeLoad(xib: nib, bundle: bundle)
                    if let uiNib = uiNib {
                        Console.shared.log("Loading XIB from resource \(nib)")
                        cache[nib] = uiNib
                        break
                    }
                }
            }
            if let uiNib = uiNib {
                Console.shared.log("Loading Content from XIB \(nib)")
                let nibContents = uiNib.instantiate(withOwner: nil, options: nil)
                let content = nibContents.first(where: { (object) -> Bool in
                    object is T
                }) as? T
                #if DEBUG
                    if let view = content as? UIView {
                        view.accessibilityIdentifier = "xib: \(nib)"
                    }
                #endif
                return content
            }
        }
        return nil
    }

    public static func loadObjects<T: NSObject>(from nib: String?) -> [T]? {
        if let nib = nib {
            var uiNib = cache[nib]
            if uiNib == nil {
                let bundles = Bundle.particles
                for bundle in bundles {
                    uiNib = UINib.safeLoad(xib: nib, bundle: bundle)
                    if let uiNib = uiNib {
                        cache[nib] = uiNib
                        break
                    }
                }
            }
            if let uiNib = uiNib {
                let nibContents = uiNib.instantiate(withOwner: nil, options: nil)
                var objects = [T]()
                for i in 0 ..< nibContents.count {
                    if let object = nibContents[i] as? T {
                        objects.append(object)
                    }
                }
                return objects
            }
        }
        return nil
    }
}
