//
//  LikedObjectsProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/19/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

@objc public protocol LikedObjectsProtocol: NSObjectProtocol {
    @objc var liked: [String]? { get set }
    @objc var disliked: [String]? { get set }
}

public extension LikedObjectsProtocol {
    func addLike(key: String?) {
        removeDislike(key: key)
        if let key = key, let liked = liked {
            if liked.firstIndex(of: key) == nil {
                var modified = liked
                modified.append(key)
                self.liked = modified
            }
        }
    }

    func removeLike(key: String?) {
        if let key = key, let liked = liked {
            if let index = liked.firstIndex(of: key) {
                var modified = liked
                modified.remove(at: index)
                self.liked = modified
            }
        }
    }

    func toggleLike(key: String?) {
        if let key = key, let liked = liked {
            var modified = liked
            if let index = liked.firstIndex(of: key) {
                modified.remove(at: index)
            } else {
                removeDislike(key: key)
                modified.append(key)
            }
            self.liked = modified
        }
    }

    func liked(key: String?) -> Bool {
        if let key = key, let liked = liked {
            return liked.firstIndex(of: key) != nil
        }
        return false
    }

    func addDislike(key: String?) {
        removeLike(key: key)
        if let key = key, let disliked = disliked {
            if disliked.firstIndex(of: key) == nil {
                var modified = disliked
                modified.append(key)
                self.disliked = modified
            }
        }
    }

    func removeDislike(key: String?) {
        if let key = key, let disliked = disliked {
            if let index = disliked.firstIndex(of: key) {
                var modified = disliked
                modified.remove(at: index)
                self.disliked = modified
            }
        }
    }

    func toggleDislike(key: String?) {
        if let key = key, let disliked = disliked {
            var modified = disliked
            if let index = disliked.firstIndex(of: key) {
                modified.remove(at: index)
            } else {
                removeLike(key: key)
                modified.append(key)
            }
            self.disliked = modified
        }
    }

    func disliked(key: String?) -> Bool {
        if let key = key, let disliked = disliked {
            return disliked.firstIndex(of: key) != nil
        }
        return false
    }
}
