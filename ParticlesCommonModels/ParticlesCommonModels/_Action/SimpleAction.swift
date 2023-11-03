//
//  ActionInteractor.swift
//  ParticlesCommonModels
//
//  Created by Qiang Huang on 2/10/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit

open class SimpleAction: DictionaryEntity, ActionProtocol {
    open var title: String? {
        return parser.asString(data?["title"])
    }

    open var subtitle: String? {
        return parser.asString(data?["subtitle"])
    }

    open var detail: String? {
        return parser.asString(data?["detail"])
    }

    open var image: String? {
        return parser.asString(data?["image"])
    }

    open var routing: RoutingRequest? {
        if let routing = parser.asDictionary(data?["routing"]), let path = parser.asString(routing["path"]) {
            return RoutingRequest(path: path, params: parser.asDictionary(routing["params"]))
        }
        return nil
    }

    open var detailRouting: RoutingRequest? {
        if let routing = parser.asDictionary(data?["detailRouting"]), let path = parser.asString(routing["path"]) {
            return RoutingRequest(path: path, params: parser.asDictionary(routing["params"]))
        }
        return nil
    }
}
