//
//  CredentialsProvider.swift
//  ParticlesKit
//
//  Created by John Huang on 7/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

open class JsonCredentialsProvider: NSObject {
    public static var parserOverwrite: Parser?

    override open var parser: Parser {
        return JsonEndpointResolver.parserOverwrite ?? super.parser
    }

    private var entity: DictionaryEntity?

    public func key(for lookupKey: String) -> String? {
        let content = entity?.data?[lookupKey]
        if let contentDict = parser.asDictionary(content) {
            let value = parser.asString(contentDict["value"])
            if value?.isNotEmpty ?? false {
                return value
            } else {
                return nil
            }
        } else {
            return parser.asString(content)
        }
    }

    override public init() {
        super.init()

        if let credentials = JsonLoader.load(bundles: Bundle.particles, fileName: "credentials.json") as? [String: Any] {
            entity = DictionaryEntity()
            entity?.parse(dictionary: credentials)
        }
    }
}

public class CredientialConfig {
    public static var shared = JsonCredentialsProvider()
}
