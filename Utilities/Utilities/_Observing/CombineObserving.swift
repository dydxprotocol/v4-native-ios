//
//  CombineObserving.swift
//  Utilities
//
//  Created by Rui Huang on 5/5/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import Foundation
import Combine

public protocol CombineObserving: AnyObject {
    var cancellableMap: [AnyKeyPath: AnyCancellable] { get set }
}

public extension CombineObserving {

    func observeTo<T>(publisher: Published<T>.Publisher?,
                      keyPath: AnyKeyPath,
                      resetCondition: (() -> Bool),
                      dedupCondition: ( (T, T) -> Bool)? = nil,
                      initial: @escaping ((_ obj: T?, _ emitState: EmitState) -> Void),
                      change: @escaping ((_ obj: T?, _ emitState: EmitState) -> Void)) {
        if resetCondition() {
            cancellableMap[keyPath]?.cancel()
            cancellableMap.removeValue(forKey: keyPath)
            if let publisher = publisher {
                _ = publisher
                    .prefix(1)
                    .sink { t in
                        DispatchQueue.main.async {
                            initial(t, .initial)
                        }
                    }

                if let dedupCondition = dedupCondition {
                    cancellableMap[keyPath] =
                        publisher
                            .dropFirst()
                            .removeDuplicates(by: dedupCondition)
                            .sink { t in
                                DispatchQueue.main.async {
                                    change(t, .change)
                                }
                            }
                } else {
                    cancellableMap[keyPath] =
                        publisher
                            .dropFirst()
                            .sink { t in
                                DispatchQueue.main.async {
                                    change(t, .change)
                                }
                            }
                }
            }
        }
    }

    func observeTo<T>(publisher: Published<T>.Publisher?,
                      keyPath: AnyKeyPath,
                      resetCondition: (() -> Bool),
                      dedupCondition: ( (T, T) -> Bool)? = nil,
                      change: @escaping ((_ obj: T?, _ emitState: EmitState) -> Void)) {
        observeTo(publisher: publisher,
                            keyPath: keyPath,
                            resetCondition: resetCondition,
                            dedupCondition: dedupCondition,
                            initial: change,
                            change: change)
    }
}

public enum EmitState {
    case initial
    case change

    public var shouldAnimate: Bool {
        switch self {
        case .initial:
            return false
        case .change:
            return true
        }
    }
}
