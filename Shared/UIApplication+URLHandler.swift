//
//  UIApplication+URLHandler.swift
//  dydxV4
//
//  Created by Michael Maguire on 8/17/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import UIKit
import Utilities

extension UIApplication: URLHandlerProtocol {
    public func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        Tracking.shared?.log(event: "NavigateExternal", data: nil)
        open(url, options: [:], completionHandler: completion)
    }
}
