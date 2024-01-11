//
//  JsonDocumentFileCaching.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/26/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

open class JsonDocumentFileCaching: NSObject, JsonCachingProtocol {
    @objc public dynamic var isLoading: Bool = false

    public var priority: Int = 0

    public var debouncer: Debouncer = Debouncer()
    public var defaultFile: String?
    public var folder: String?

    public init(priority: Int = 0, defaultFile: String? = nil) {
        super.init()
        self.priority = priority
        self.defaultFile = defaultFile
    }

    public func file(path: String) -> String? {
        if folder == nil {
            folder = FolderService.shared?.documents()
        }
        return folder?.stringByAppendingPathComponent(path: path).stringByAppendingPathComponent(path: "data.json")
    }

    public func defaultFile(path: String?) -> String? {
        if let path = path {
            return Bundle.main.bundlePath.stringByAppendingPathComponent(path: path)
        } else {
            return nil
        }
    }

    open func read(path: String, completion: @escaping JsonReadCompletionHandler) {
        let object = read(path: path)
        completion(object, nil)
    }

    open func read(path: String) -> Any? {
        if let file = file(path: path) {
            var object = JsonLoader.load(file: file)
            if object == nil {
                if let defaultFile = self.defaultFile(path: defaultFile) {
                    object = JsonLoader.load(file: defaultFile)
                }
            }
            return object
        } else {
            return nil
        }
    }

    open func write(path: String, data: Any?, completion: JsonWriteCompletionHandler?) {
        if let file = file(path: path) {
            if let handler = debouncer.debounce() {
                handler.run(background: {
                    JsonWriter.write(data, to: file)
                }, final: {
                    completion?(nil)
                }, delay: 0.5)
            }
        } else {
            completion?(NSError(domain: "file", code: 0, userInfo: ["message": "document folder error"]))
        }
    }
}
