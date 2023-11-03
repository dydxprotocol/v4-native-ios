//
//  ObjectLikeBarItemPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 11/2/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

@objc open class ObjectLikeBarItemPresenter: ObjectPresenter {
    @IBOutlet var likeButton: ButtonProtocol? {
        didSet {
            if likeButton !== oldValue {
                oldValue?.removeTarget()
                likeButton?.addTarget(self, action: #selector(like(_:)))
                updateLiked()
            }
        }
    }

    @IBOutlet var dislikeButton: ButtonProtocol? {
        didSet {
            if dislikeButton !== oldValue {
                oldValue?.removeTarget()
                dislikeButton?.addTarget(self, action: #selector(dislike(_:)))
                updateDisliked()
            }
        }
    }

    public var likedManager: LikedObjectsProtocol? {
        didSet {
            changeObservation(from: oldValue, to: likedManager, keyPath: #keyPath(LikedObjectsProtocol.liked)) { [weak self] _, _, _, _ in
                self?.updateLiked()
            }

            changeObservation(from: oldValue, to: likedManager, keyPath: #keyPath(LikedObjectsProtocol.disliked)) { [weak self] _, _, _, _ in
                self?.updateDisliked()
            }
        }
    }

    override open var model: ModelObjectProtocol? {
        didSet {
            if model !== oldValue {
                self.updateLiked()
                self.updateDisliked()
            }
        }
    }

    open func updateLiked() {
        if let key = model?.key {
            if likedManager?.liked(key: key) ?? false {
                likeButton?.buttonImage = UIImage.named("action_liked", bundles: Bundle.particles)
            } else {
                likeButton?.buttonImage = UIImage.named("action_like", bundles: Bundle.particles)
            }
        }
    }

    open func updateDisliked() {
        if let key = model?.key {
            if likedManager?.disliked(key: key) ?? false {
                dislikeButton?.buttonImage = UIImage.named("action_disliked", bundles: Bundle.particles)
            } else {
                dislikeButton?.buttonImage = UIImage.named("action_dislike", bundles: Bundle.particles)
            }
        }
    }

    @IBAction func like(_ sender: Any?) {
        if let key = model?.key, let likedManager = self.likedManager {
            likedManager.toggleLike(key: key)
        }
    }

    @IBAction func dislike(_ sender: Any?) {
        if let key = model?.key, let likedManager = self.likedManager {
            likedManager.toggleDislike(key: key)
        }
    }
}
