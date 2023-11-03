//
//  SavedSearch.swift
//  EntityLib
//
//  Created by Qiang Huang on 10/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

open class SavedSearchEntity: DictionaryEntity {
    open var name: String? {
        get { return parser.asString(data?["name"]) }
        set {
            if data == nil {
                data = [String: Any]()
            }
            data?["name"] = newValue
        }
    }

    open var text: String? {
        get { return parser.asString(data?["text"]) }
        set {
            if data == nil {
                data = [String: Any]()
            }
            data?["text"] = newValue
        }
    }

    open var filters: [String: Any]? {
        get { return parser.asDictionary(data?["fitlers"]) }
        set {
            if data == nil {
                data = [String: Any]()
            }
            data?["filters"] = newValue
        }
    }
}
