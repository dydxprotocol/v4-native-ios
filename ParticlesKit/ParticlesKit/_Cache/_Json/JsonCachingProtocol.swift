//
//  JsonCachingProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/26/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public typealias JsonReadCompletionHandler = (_ data: Any?, _ error: Error?) -> Void
public typealias JsonWriteCompletionHandler = (_ error: Error?) -> Void

public protocol JsonCachingProtocol: IOProtocol {
    func read(path: String, completion: @escaping JsonReadCompletionHandler)
    func write(path: String, data: Any?, completion: JsonWriteCompletionHandler?)
}

extension JsonCachingProtocol {
    public func load(path: String, params: [String: Any]?, completion: @escaping IOReadCompletionHandler) {
        var path = path
        if let params = params {
            for (_, value) in params {
                if let string = value as? String {
                    path = path.stringByAppendingPathComponent(path: string)
                }
            }
        }
        isLoading = true
        read(path: path) { [weak self] data, error in
            self?.isLoading = false
            completion(data, nil, self?.priority ?? 0, error)
        }
    }

    public func save(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
        write(path: path, data: data) { error in
            completion?(data, error)
        }
    }

    public func modify(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
        write(path: path, data: data) { error in
            completion?(data, error)
        }
    }

    public func delete(path: String, params: [String: Any]?, completion: IODeleteCompletionHandler?) {
    }
}
