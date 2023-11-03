//
//  LikeDoer.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/2/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit

public enum LikeDoerAction {
    case like
    case dislike
}

public class LikeDoer: DoerProtocol {
    public var likedManager: LikedObjectsProtocol?
    public var key: String?
    public var action: LikeDoerAction

    public var liked: Bool = false
    public var disliked: Bool = false

    public init(_ action: LikeDoerAction, likedManager: LikedObjectsProtocol?, key: String?) {
        self.action = action
        self.likedManager = likedManager
        self.key = key
    }

    public func perform() -> Bool {
        if let likedManager = likedManager, let key = key {
            liked = likedManager.liked(key: key)
            disliked = likedManager.disliked(key: key)
            switch action {
            case .like:
                likedManager.toggleLike(key: key)
                return true

            case .dislike:
                likedManager.toggleDislike(key: key)
                return true
            }
        }
        return false
    }

    public func undo() {
        if liked {
            likedManager?.addLike(key: key)
        } else {
            likedManager?.removeLike(key: key)
        }
        if disliked {
            likedManager?.addDislike(key: key)
        } else {
            likedManager?.removeDislike(key: key)
        }
    }
}
