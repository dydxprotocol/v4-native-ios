//
//  FieldInteractor.swift
//  FieldInteractorLib
//
//  Created by Qiang Huang on 10/15/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities

@objc public class FieldOutput: NSObject, FieldOutputProtocol, RoutingOriginatorProtocol {
    public var visible: Bool {
        fieldOutput?.visible ?? false
    }
    
    @objc public dynamic var field: FieldDefinition? {
        didSet {
            if field !== oldValue {
                updateChildren()
            }
        }
    }

    @objc public dynamic var entity: ModelObjectProtocol? {
        didSet {
            if entity !== oldValue {
                updateChildren()
            }
        }
    }

    public var title: String? {
        return text(fieldOutput?.title)
    }

    public var subtitle: String? {
        return text(fieldOutput?.subtitle)
    }

    public var text: String? {
        var text = self.text(fieldOutput?.text)
        return text
    }

    public var subtext: String? {
        return text(fieldOutput?.subtext)
    }

    public var checked: Bool? {
        return bool(fieldOutput?.checked)
    }

    @objc public dynamic var link: String? {
        return text(fieldOutput?.link)
    }

    @objc public dynamic var strings: [String]? {
        return strings(fieldOutput?.strings)
    }

    @objc public dynamic var images: [String]? {
        return strings(fieldOutput?.images)
    }

    public var items: [FieldOutputProtocol]?

    @objc public dynamic var hasData: Bool {
        if entity != nil && fieldOutput != nil {
            return hasData(fieldOutput?.title) || hasData(fieldOutput?.subtitle) || hasData(fieldOutput?.text) || hasData(fieldOutput?.subtext) || hasData(fieldOutput?.image) || hasData(fieldOutput?.checked) || hasData(fieldOutput?.strings) || hasData(fieldOutput?.images) || hasData(fieldOutput?.link, textOK: true) || (items?.count ?? 0) > 0
        }
        return false
    }

    public func updateChildren() {
        if let definitions = fieldOutput?.items {
            var fields: [FieldOutput] = [FieldOutput]()
            for definition in definitions {
                let field = FieldOutput()
                field.entity = entity
                field.field = definition
                if field.hasData {
                    fields.append(field)
                }
            }
            if fields.count > 0 {
                items = fields
            } else {
                items = nil
            }
        } else {
            items = nil
        }
    }

    public func routingRequest() -> RoutingRequest? {
        if let link = link {
            return RoutingRequest(url: link)
        }
        return nil
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let output2 = object as? FieldOutput {
            return text == output2.text && title == output2.title && subtitle == output2.subtitle && checked == output2.checked && image == output2.image && strings == output2.strings && images == output2.images && link == output2.link
        } else {
            return false
        }
    }
}
