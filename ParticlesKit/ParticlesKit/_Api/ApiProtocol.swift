//
//  ApiProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/26/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public typealias ApiCompletionHandler = (_ data: Any?, _ error: Error?) -> Void
// for upload or download
public typealias ApiProgressHandler = (_ progress: Float) -> Void

public protocol ApiProtocol: IOProtocol {
    func get(path: String, params: [String: Any]?, completion: @escaping ApiCompletionHandler)
    func post(path: String, params: [String: Any]?, data: Any?, completion: @escaping ApiCompletionHandler)
    func put(path: String, params: [String: Any]?, data: Any?, completion: @escaping ApiCompletionHandler)
    func delete(path: String, params: [String: Any]?, completion: @escaping ApiCompletionHandler)
}

extension ApiProtocol {
    public func load(path: String, params: [String: Any]?, completion: @escaping IOReadCompletionHandler) {
        get(path: path, params: params) { [weak self] data, error in
            completion(data, nil, self?.priority ?? 10, error)
        }
    }

    public func save(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
        post(path: path, params: params, data: data) { data, error in
            completion?(data, error)
        }
    }

    public func modify(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
        put(path: path, params: params, data: data) { data, error in
            completion?(data, error)
        }
    }

    public func delete(path: String, params: [String: Any]?, completion: IODeleteCompletionHandler?) {
        delete(path: path, params: params) { _, error in
            completion?(error)
        }
    }
}

extension ApiProtocol {
    // implement later
    public func post(path: String, params: [String: Any]?, data: Any?, completion: @escaping ApiCompletionHandler) {
    }

    public func put(path: String, params: [String: Any]?, data: Any?, completion: @escaping ApiCompletionHandler) {
    }

    public func delete(path: String, params: [String: Any]?, completion: @escaping ApiCompletionHandler) {
    }
}
