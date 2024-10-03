//
//  NavigationObject.swift
//  ParticlesCommonModels
//
//  Created by Qiang Huang on 1/30/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit

public class NavigationObject: DictionaryEntity, NavigationModelProtocol {
    @objc public var type: String? {
        return parser.asString(data?["type"])
    }

    @objc public var title: String? {
        return parser.asString(data?["title"])
    }

    @objc public var subtitle: String? {
        return parser.asString(data?["subtitle"])
    }

    @objc public var text: String? {
        return parser.asString(data?["text"])
    }

    @objc public var subtext: String? {
        return parser.asString(data?["subtext"])
    }

    @objc public var color: String? {
        return parser.asString(data?["color"])
    }

    @objc public var icon: URL? {
        return parser.asURL(data?["icon"])
    }

    @objc public var image: URL? {
        return parser.asURL(data?["image"])
    }

    @objc public var link: URL? {
        return parser.asURL(data?["link"])
    }

    @objc public var tag: String? {
        return parser.asString(data?["tag"])
    }

    @objc public var children: [NavigationModelProtocol]?
    @objc public var actions: [NavigationModelProtocol]?

    override public func parse(dictionary: [String: Any]) {
        super.parse(dictionary: dictionary)

        if let childrenData = parser.asArray(dictionary["children"]) as? [[String: Any]] {
            var children = [NavigationModelProtocol]()
            for childData in childrenData {
                let child = NavigationObject()
                child.parse(dictionary: childData)
                children.append(child)
            }
            self.children = children
        } else {
            children = nil
        }

        if let actionsData = parser.asArray(dictionary["actions"]) as? [[String: Any]] {
            var actions = [NavigationModelProtocol]()
            for actionData in actionsData {
                let action = NavigationObject()
                action.parse(dictionary: actionData)
                actions.append(action)
            }
            self.actions = actions
        } else {
            actions = nil
        }
    }
}
