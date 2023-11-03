//
//  UserAgent.swift
//  Utilities
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

public protocol UserAgentProtocol: NSObjectProtocol {
    func userAgent() -> String?
}

public class UserAgentProvider: NSObject {
    public static var shared: UserAgentProtocol?
}
