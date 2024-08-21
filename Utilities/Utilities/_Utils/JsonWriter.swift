//
//  JsonWriter.swift
//  Utilities
//
//  Created by Qiang Huang on 11/24/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public class JsonWriter {
    public static func write(_ object: Any?, to file: String?) {
        if let object = object, let file = file {
            do {
                File.delete(file)
                _ = Directory.ensure(file.stringByDeletingLastPathComponent)
                let json = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
                try json.write(to: URL(fileURLWithPath: file))
            } catch {
            }
        }
    }
}
