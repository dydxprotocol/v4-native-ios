//
//  IOProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/29/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public typealias IOReadCompletionHandler = (_ data: Any?, _ meta: Any?, _ priority: Int, _ error: Error?) -> Void
public typealias IOWriteCompletionHandler = (_ data: Any?, _ error: Error?) -> Void
public typealias IODeleteCompletionHandler = (_ error: Error?) -> Void

public protocol IOProtocol: NSObjectProtocol {
    var priority: Int { get set }
    var isLoading: Bool { get set }
    func load(path: String, params: [String: Any]?, completion: @escaping IOReadCompletionHandler)
    func save(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?)
    func modify(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?)
    func delete(path: String, params: [String: Any]?, completion: IODeleteCompletionHandler?)
}
