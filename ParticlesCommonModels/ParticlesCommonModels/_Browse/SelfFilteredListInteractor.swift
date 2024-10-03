//
//  SelfFilteredListInteractor.swift
//  SelfFilteredListInteractor
//
//  Created by Qiang Huang on 7/29/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit

@objc open class SelfFilteredListInteractor: FilteredListInteractor {
    @objc public dynamic var pool: [ModelObjectProtocol]? {
        didSet {
            didSetPool(oldValue: oldValue)
        }
    }

    public override var data: [ModelObjectProtocol]? {
        return pool
    }

    private func didSetPool(oldValue: [ModelObjectProtocol]?) {
        filter()
    }

    public override func sort(data: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return data
    }

    public override func filter(data: ModelObjectProtocol, text: String?) -> Bool {
        if let list = data as? FilteredListInteractorProtocol {
            list.filterText = text
        }
        return true
    }
}
