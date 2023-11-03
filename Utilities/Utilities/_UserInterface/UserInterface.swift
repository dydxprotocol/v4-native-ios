//
//  UserInterface.swift
//  Utilities
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

public enum InterfaceType {
    case phone
    case pad
    case watch
    case car
    case tv
    case mac
    case voice
    case none
}

public protocol UserInterfaceProtocol: NSObjectProtocol {
    var type: InterfaceType? { get }
}

public class UserInterface {
    public static var shared: UserInterfaceProtocol?
}
