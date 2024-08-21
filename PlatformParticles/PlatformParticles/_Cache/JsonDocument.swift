//
//  JsonDocument.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

open class JsonDocument: UIDocument {
    public var data: Any?

    override open func contents(forType typeName: String) throws -> Any {
        if let data = data {
            return try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        } else {
            return Data()
        }
    }

    override open func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            data = try? JSONSerialization.jsonObject(with: json, options: [])
        } else {
            data = nil
        }
    }
}
