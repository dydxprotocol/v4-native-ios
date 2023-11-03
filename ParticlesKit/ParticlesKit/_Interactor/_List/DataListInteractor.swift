//
//  DataListInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/27/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

@objc open class DataListInteractor: LocalJsonCacheInteractor {
    @objc open dynamic var data: [ModelObjectProtocol]?

    override open func receive(io: IOProtocol?, object: Any?, loadTime: Date?, error: Error?) {
        if error == nil {
            if var data = data {
                if let newObjects = object as? [ModelObjectProtocol] {
                    data.append(contentsOf: newObjects)
                }
            } else {
                data = object as? [ModelObjectProtocol]
            }
        }
    }
}
