//
//  dydxCollectFeedbackActionBuilder.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 2/27/24.
//

import RoutingKit
import Utilities
import UIToolkits
import dydxStateManager

public class dydxCollectFeedbackActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = dydxCollectFeedbackAction()
        return action as? T
    }
}

open class dydxCollectFeedbackAction: NSObject, NavigableProtocol {
    private var completion: RoutingCompletionBlock?
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
    case "/action/collect_feedback":
            if let feedbackUrl = URL(string: AbacusStateManager.shared.environment?.links?.feedback ?? "") {
                let data: [String: String]?
                if let shareSource = request?.params?["context"] as? String {
                    data = ["source_context": shareSource]
                } else {
                    data = nil
                }
                Router.shared?.navigate(to: feedbackUrl, completion: { _, success in
                    completion?(nil, success)
                })
                Tracking.shared?.log(event: "CollectFeedbackDisplayed", data: data)
                completion?(nil, true)
            } else {
                completion?(nil, false)
            }
        default:
            completion?(nil, false)
        }
    }
}
