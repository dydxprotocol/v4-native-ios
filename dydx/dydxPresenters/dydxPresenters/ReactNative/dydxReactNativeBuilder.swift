//
//  dydxReactNativeBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 09/04/2025.
//

import Foundation
import ParticlesKit
import PlatformUI
import RoutingKit
import Utilities

public class dydxReactNativeBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        // Sample
        return dydxReactViewController(moduleName: "TurnkeyReact") as? T
    }
}
