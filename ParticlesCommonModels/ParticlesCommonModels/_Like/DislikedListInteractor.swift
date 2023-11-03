//
//  DislikedListInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 10/23/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

@objc open class DislikedListInteractor: ListInteractor {
    open var dataCache: DataPoolInteractor? {
        didSet {
            changeObservation(from: oldValue, to: dataCache, keyPath: #keyPath(DataPoolInteractor.data)) { [weak self] _, _, _, _ in
                self?.update()
            }
        }
    }

    open var likedManager: LikedKeysInteractor? {
        didSet {
            changeObservation(from: oldValue, to: likedManager, keyPath: #keyPath(LikedKeysInteractor.disliked)) { [weak self] _, _, _, _ in
                self?.update()
            }
        }
    }

    public override init() {
        super.init()
        setup()
    }

    open func setup() {
    }

    open func update() {
        if let data = self.dataCache?.data, let disliked = self.likedManager?.disliked {
            var dislikes = [ModelObjectProtocol]()
            for key in disliked {
                if let object = data[key] {
                    dislikes.append(object)
                }
            }
            sync(dislikes)
        } else {
            sync(nil)
        }
    }
}
