//
//  JsonAppGroupFileCaching.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 12/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

open class JsonAppGroupFileCaching: NSObject, JsonCachingProtocol {
    @objc public dynamic var isLoading: Bool = false

    public var priority: Int = 0

    public var debouncer: Debouncer = Debouncer()
    public var groupUrl: URL?
    public var document: JsonDocument?

    public func file(path: String) -> URL? {
        return groupUrl?.appendingPathComponent(path).appendingPathComponent("data.json")
    }

    public init(appGroup: String, priority: Int = 0) {
        super.init()
        groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
        self.priority = priority
    }

    open func read(path: String, completion: @escaping JsonReadCompletionHandler) {
        if let handler = debouncer.debounce() {
            handler.run({ [weak self] in
                if let self = self, let file = self.file(path: path), FileManager.default.fileExists(atPath: file.path) {
                    self.document = JsonDocument(fileURL: file)
                    self.document?.open(completionHandler: { [weak self] (success: Bool) -> Void in
                        if let self = self {
                            if success {
                                let data = self.document?.data
                                self.document = nil
                                completion(data, nil)
                            } else {
                                self.document = nil
                                completion(nil, nil)
                            }
                        }
                    })
                } else {
                    completion(nil, nil)
                }
            }, delay: 0.5)
        }
    }

    open func write(path: String, data: Any?, completion: JsonWriteCompletionHandler?) {
        if let file = file(path: path) {
            _ = Directory.ensure(file.deletingLastPathComponent().path)
            let writeOption: UIDocument.SaveOperation = FileManager.default.fileExists(atPath: file.path) ? .forOverwriting : .forCreating
            document = JsonDocument(fileURL: file)
            document?.data = data
            document?.save(to: file, for: writeOption, completionHandler: { (success: Bool) in
                if success {
                    completion?(nil)
                } else {
                    completion?(NSError(domain: "file", code: 0, userInfo: nil))
                }
            })
        } else {
            completion?(nil)
        }
    }
}
