//
//  JsonEndpointResolver.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 7/15/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

open class JsonEndpointResolver: NSObject & EndpointResolverProtocol {
    public static var parserOverwrite: Parser?

    override open var parser: Parser {
        return JsonEndpointResolver.parserOverwrite ?? super.parser
    }

    private var entity: DictionaryEntity?

    public var host: String? {
        if let host = parser.asString(parser.asDictionary(entity?.data)?["host"]) {
            if let custom = parser.asString(DebugSettings.shared?.debug?[host]) {
                return custom
            } else {
                return host
            }
        }
        return nil
    }

    public func path(for action: String) -> String? {
        return parser.asString(parser.asDictionary(parser.asDictionary(entity?.data)?["path"])?[action])
    }

    public init(json: String) {
        super.init()

        if let destinations = JsonLoader.load(bundles: Bundle.particles, fileName: json) as? [String: Any] {
            entity = DictionaryEntity()
            entity?.parse(dictionary: destinations)
        }
    }
}
