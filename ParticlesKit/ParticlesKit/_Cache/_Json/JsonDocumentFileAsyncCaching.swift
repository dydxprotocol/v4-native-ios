//
//  JsonDocumentFileAsyncCaching.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/29/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

open class JsonDocumentFileAsyncCaching: JsonDocumentFileCaching {
    open override func read(path: String, completion: @escaping JsonReadCompletionHandler) {
        DispatchQueue.global().async {[weak self] in
            let object = self?.read(path: path)
            DispatchQueue.main.async {
                completion(object, nil)
            }
        }
    }
}
