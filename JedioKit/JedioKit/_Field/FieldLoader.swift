//
//  FieldLoader.swift
//  JedioKit
//
//  Created by Qiang Huang on 4/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

@objc open class FieldLoader: NSObject {
    @IBInspectable @objc public dynamic var definitionFile: String? {
        didSet {
            if definitionFile != oldValue {
                definitionGroups = load()
            }
        }
    }

    @objc public dynamic var definitionGroups: [FieldDefinitionGroup]?

    open func load() -> [FieldDefinitionGroup]? {
        let json = JsonLoader.load(bundles: Bundle.particles, fileName: definitionFile)
        if let jsonDictionary = json as? [[String: Any]] {
            var definitions = [FieldDefinitionGroup]()
            for itemDictionary in jsonDictionary {
                if let parsed = parser.asDictionary(itemDictionary) {
                    let definition = FieldDefinitionGroup()
                    definition.parse(dictionary: parsed)
                    definitions.append(definition)
                }
            }
            return definitions
        }
        return nil
    }

    override open var parser: Parser {
        return Parser.featureFlagged
    }
}
