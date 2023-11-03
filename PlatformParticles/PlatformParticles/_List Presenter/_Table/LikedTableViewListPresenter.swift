//
//  LikedTableViewListPresenter.swift
//  PresenterLib
//
//  Created by Qiang Huang on 11/9/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import Utilities
import ParticlesCommonModels

open class LikedTableViewListPresenter: TableViewListPresenter {
    @IBInspectable public var likePath: String?
    @IBInspectable public var dislikePath: String?

    @IBOutlet open var likedManager: LikedObjectsProtocol?

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let entity = object(indexPath: indexPath), let key = entity.key, let actions = swipeActions(key: key) {
            let swipeConfig = UISwipeActionsConfiguration(actions: actions)
            return swipeConfig
        }
        return nil
    }

    open func swipeActions(key: String?) -> [UIContextualAction]? {
        if let key = key {
            if let like = likeAction(key: key) {
                var actions = [like]
                if let dislike = dislikeAction(key: key) {
                    actions.append(dislike)
                }
                return actions
            }
        }
        return nil
    }

    open func likeAction(key: String) -> UIContextualAction? {
        if let path = likePath {
            let likeAction = UIContextualAction(style: .normal, title: "Like") { /* [weak self] */ _, _, completionHandler in
                Router.shared?.navigate(to: RoutingRequest(path: path, params: ["key": key]), animated: false, completion: { _, _ in
                    completionHandler(true)
                })
            }
            let liked = (likedManager ?? (interactor as? FilteredListInteractor)?.liked)?.liked(key: key) ?? false
            likeAction.image = UIImage(systemName: liked ? "star.fill" : "star")
            return likeAction
        } else {
            return nil
        }
    }

    open func dislikeAction(key: String) -> UIContextualAction? {
        if let path = dislikePath {
            let dislikeAction = UIContextualAction(style: .normal, title: "Dislike") { /* [weak self] */ _, _, completionHandler in

                Router.shared?.navigate(to: RoutingRequest(path: path, params: ["key": key]), animated: false, completion: { _, _ in
                    completionHandler(true)
                })
            }
            let disliked = (likedManager ?? (interactor as? FilteredListInteractor)?.liked)?.disliked(key: key) ?? false
            dislikeAction.title = disliked ? "It's\nOK" : "Not\nInterested"
            dislikeAction.backgroundColor = UIColor.red
            return dislikeAction
        } else {
            return nil
        }
    }
}
