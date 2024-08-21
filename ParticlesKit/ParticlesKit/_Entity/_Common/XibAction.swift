//
//  XibAction.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 8/12/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import RoutingKit
import Utilities

@objc open class XibAction: NSObject, XibProviderProtocol, ModelObjectProtocol, SelectableProtocol, ParsingProtocol, RoutingOriginatorProtocol {
    @objc public dynamic var isSelected: Bool = false
    @objc public dynamic var xib: String?
    @objc public dynamic var title: String?
    @objc public dynamic var text: String?
    @objc public dynamic var image: String?
    @objc public dynamic var color: String?
    @objc public dynamic var request: RoutingRequest?

    public func routingRequest() -> RoutingRequest? {
        return request
    }

    public static func load(file: String) -> [XibAction]? {
        var actions: [XibAction]?
        let bundles = Bundle.particles
        for bundle in bundles {
            actions = load(file: file, bundle: bundle)
            if actions != nil {
                break
            }
        }
        return actions
    }

    public static func load(file: String, bundle: Bundle) -> [XibAction]? {
        if let data = JsonLoader.load(bundle: bundle, fileName: file) as? [[String: Any]] {
            var objects = [XibAction]()
            for item in data {
                let object = XibAction()
                object.parse(dictionary: item)
                objects.append(object)
            }
            return objects.count > 0 ? objects : nil
        }
        return nil
    }

    public func parse(dictionary: [String: Any]) {
        xib = parser.asString(dictionary["xib"])
        title = parser.asString(dictionary["title"])
        text = parser.asString(dictionary["text"])
        image = parser.asString(dictionary["image"])
        color = parser.asString(dictionary["color"])
        if let url = parser.asString(dictionary["url"]) {
            request = RoutingRequest(url: url)
        }
    }
}
