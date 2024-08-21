//
//  AsyncEvent.swift
//  Utilities
//
//  Created by Rui Huang on 1/30/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import Foundation
import Combine

public enum AsyncEvent<ProgressType, ResultType> {
    case progress(ProgressType)
    case result(ResultType?, Error?)
}

public protocol AsyncStep {
    associatedtype ProgressType
    associatedtype ResultType
    func run() -> AnyPublisher<AsyncEvent<ProgressType, ResultType>, Never>
}
