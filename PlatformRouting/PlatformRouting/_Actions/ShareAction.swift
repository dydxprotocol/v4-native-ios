//
//  ShareAction.swift
//  PlatformRouting
//
//  Created by Qiang Huang on 11/2/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import RoutingKit
import Utilities
import UIToolkits

public class ShareActionBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let action = ShareAction()
        return action as? T
    }
}

open class ShareAction: NSObject, NavigableProtocol {
    private var completion: RoutingCompletionBlock?
    open func navigate(to request: RoutingRequest?, animated: Bool, completion: RoutingCompletionBlock?) {
        switch request?.path {
        case "/action/share":
            if let text = parser.asString(request?.params?["text"])?.decodeUrl(), let link = parser.asString(request?.params?["link"]), let linkUrl = NSURL(string: link) {
                let toShare: [Any] = [text, linkUrl]
                let activityVC = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [
                    UIActivity.ActivityType.airDrop,
                    UIActivity.ActivityType.addToReadingList,
                ]

                activityVC.popoverPresentationController?.sourceView = UserInteraction.shared.sender as? UIView
                activityVC.popoverPresentationController?.barButtonItem = UserInteraction.shared.sender as? UIBarButtonItem
                UIViewController.topmost()?.present(activityVC, animated: true, completion: nil)
                
                let data: [String: String]?
                if let shareSource = request?.params?["share_source"] as? String {
                    data = ["share_source": shareSource]
                } else {
                    data = nil
                }
                Tracking.shared?.log(event: "ShareDialogDisplayed", data: data)
                completion?(nil, true)
            } else {
                completion?(nil, false)
            }
        default:
            completion?(nil, false)
        }
    }
}
