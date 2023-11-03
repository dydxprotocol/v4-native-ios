//
//  JsonLoader.swift
//  Utilities
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

@objc public class StringLoader: NSObject {
    @objc public class func load(file: String) -> String? {
        let fileUrl = URL(fileURLWithPath: file)
        guard let data = try? Data(contentsOf: fileUrl) else {
            return nil
        }
        return String(decoding: data, as: UTF8.self)
    }

    @objc public class func load(bundle: Bundle, fileName: String?) -> String? {
        if let fileName = fileName {
            let file = bundle.bundlePath.stringByAppendingPathComponent(path: fileName)
            return load(file: file)
        }
        return nil
    }

    @objc public class func load(bundles: [Bundle], fileName: String?) -> String? {
        var value: String?
        for bundle in bundles {
            value = load(bundle: bundle, fileName: fileName)
            if value != nil {
                break
            }
        }
        return value
    }

    @objc public class func load(bundled fileName: String?) -> String? {
        return load(bundle: Bundle.main, fileName: fileName)
    }
}
