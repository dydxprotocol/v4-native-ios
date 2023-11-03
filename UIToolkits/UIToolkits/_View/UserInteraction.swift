//
//  UserInteraction.swift
//  UIToolkits
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Utilities

public final class UserInteraction: NSObject, SingletonProtocol {
    public static var shared: UserInteraction = UserInteraction()

    public var sender: Any?
    public var rect: CGRect?
}
