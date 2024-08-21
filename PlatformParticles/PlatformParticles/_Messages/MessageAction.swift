//
//  MessageAction.swift
//  MessageParticles
//
//  Created by John Huang on 12/28/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Messages
import ParticlesKit
import RoutingKit
import Utilities

open class MessageAction: NSObject, NavigableProtocol {
    public weak var conversation: MSConversation?
    @IBOutlet var interactor: LoadingObjectInteractor? {
        didSet {
            changeObservation(from: oldValue, to: interactor, keyPath: #keyPath(LoadingObjectInteractor.entity)) { [weak self] _, _, _, _ in
                self?.updateMessage()
            }
        }
    }

    public override init() {
        super.init()
    }

    public func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
    }

    open func updateMessage() {
        if let conversation = conversation, let entity = interactor?.entity as? (ModelObjectProtocol & RoutingOriginatorProtocol), let request = entity.routingRequest(), let path = request.path {
            var components = URLComponents()
            components.host = "go.to"
            components.scheme = "retslyapp"
            components.path = path
            var queryItems = [URLQueryItem]()
            if let params = request.params {
                for param in params {
                    if let value = parser.asString(param.value) {
                        queryItems.append(URLQueryItem(name: param.key, value: value))
                    }
                }
                components.queryItems = queryItems
            }

            let layout = MSMessageTemplateLayout()
            layout.caption = entity.displayTitle ?? ""

            let message = MSMessage(session: conversation.selectedMessage?.session ?? MSSession())
            message.url = components.url!
            message.layout = layout

            conversation.insert(message) { error in
                if let error = error {
                    Console.shared.log(error)
                }
            }
        }
    }
}
