//
//  LoaderProtocol.swift
//  LoaderLib
//
//  Created by Qiang Huang on 10/11/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public protocol LoaderProtocol {
    var isLoading: Bool { get }
    func load(params: [String: Any]?, completion: LoaderCompletionHandler?)
    func parse(io: IOProtocol?, data: Any?, error: Error?, completion: LoaderCompletionHandler?)
    func save(object: Any?)
    func createEntity() -> ModelObjectProtocol
}

// loadingTime is used for differentiated loading
// if error is not nil, something happened
public typealias LoaderCompletionHandler = (_ io: IOProtocol?, _ loadedObject: Any?, _ loadTime: Date?, _ error: Error?) -> Void
