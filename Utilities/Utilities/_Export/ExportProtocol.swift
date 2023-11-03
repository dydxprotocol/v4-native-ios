//
//  ExportProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 12/23/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Foundation

public protocol DataExportProtocol {
    var columes: [String]? { get }
    var fileName: String? { get }
    var memeType: String? { get }
    func text(line: Int, colume: String) -> String?
}

public extension DataExportProtocol {
    func export() -> Data? {
        if let columes = columes {
            var lines = [String]()
            lines.append(join(items: columes, withQuotes: false))
            var index = 0
            var lineItems: [String]?
            repeat {
                lineItems = text(line: index, columes: columes)
                if let lineItems = lineItems {
                    lines.append(join(items: lineItems, withQuotes: true))
                    index += 1
                }
            } while lineItems != nil
            let text = lines.joined(separator: "\n")
            return text.data(using: .utf8)
        } else {
            return nil
        }
    }

    func text(line: Int, columes: [String]) -> [String]? {
        var items = [String]()
        var result = true
        for colume in columes {
            if let item = text(line: line, colume: colume) {
                items.append(item)
            } else {
                result = false
                break
            }
        }
        return result ? items : nil
    }

    func join(items: [String], withQuotes: Bool) -> String {
        if withQuotes {
            return items.map { item in
                "\"\(item)\""
            }.joined(separator: ",")
        } else {
            return items.joined(separator: ",")
        }
    }
}

public protocol ExporterProtocol {
    func export(exporters: [DataExportProtocol]?)
}

public class Exporter {
    public static var shared: ExporterProtocol?
}
