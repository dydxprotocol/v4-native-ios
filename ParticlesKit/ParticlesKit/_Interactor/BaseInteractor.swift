//
//  BaseInteractor.swift
//  ParticlesKit
//
//  Created by Rui Huang on 5/7/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation
import Utilities
import Combine

open class BaseInteractor: NSObject, CombineObserving {
    public var cancellableMap = [AnyKeyPath: AnyCancellable]()
}
