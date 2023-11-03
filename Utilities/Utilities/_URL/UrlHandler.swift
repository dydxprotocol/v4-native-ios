//
//  UrlHandler.swift
//  Utilities
//
//  Created by Qiang Huang on 8/21/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol URLHandlerProtocol {
    func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?)
    func canOpenURL(_ url: URL) -> Bool
}

public class URLHandler {
    public static var shared: URLHandlerProtocol?
}
