//
//  NSObject+Observing.swift
//  Utilities
//
//  Created by Qiang Huang on 8/7/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation
import KVOController

public typealias KVONotificationBlock = (_ observer: Any?, _ obj: Any, _ change: [String: Any], _ animated: Bool) -> Void

extension NSObject {
    public func changeObservation(from: NSObjectProtocol?, to: NSObjectProtocol?, keyPath: String, initial: KVONotificationBlock?, change: KVONotificationBlock?) {
        if from !== to {
            kvoController.unobserve(from, keyPath: keyPath)
            if let to = to {
                initial?(self, NSNull(), [:], false)
                if let change = change {
                    kvoController.observe(to, keyPath: keyPath, options: [.new, .old]) { observer, keyPath, changes in
                        if let old = changes["old"], let new = changes["new"] {
                            if let oldValue = old as? String, let newValue = new as? String {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldValue = old as? Date, let newValue = new as? Date {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldValue = old as? NSDecimalNumber, let newValue = new as? NSDecimalNumber {
                                if oldValue.decimalValue != newValue.decimalValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldValue = old as? NSNumber, let newValue = new as? NSNumber {
                                if oldValue.doubleValue != newValue.doubleValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldValue = old as? Bool, let newValue = new as? Bool {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldValue = old as? Int, let newValue = new as? Int {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldValue = old as? Float, let newValue = new as? Float {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldValue = old as? Double, let newValue = new as? Double {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldValue = old as? TimeInterval, let newValue = new as? TimeInterval {
                                if oldValue != newValue {
                                    change(observer, keyPath, changes, true)
                                }
                            } else if let oldObject = old as? NSObject, let newObject = new as? NSObject {
                                if oldObject !== newObject {
                                    change(observer, keyPath, changes, true)
                                }
                            } else {
                                change(observer, keyPath, changes, true)
                            }
                        } else {
                            change(observer, keyPath, changes, true)
                        }
                    }
                }
            } else {
                initial?(self, NSNull(), [:], false)
            }
        }
    }

    public func changeObservation(from: NSObjectProtocol?, to: NSObjectProtocol?, keyPath: String, block: @escaping KVONotificationBlock) {
        changeObservation(from: from, to: to, keyPath: keyPath, initial: block, change: block)
    }

    public func run(_ function: () -> Void, notify: String) {
        willChangeValue(forKey: notify)
        function()
        didChangeValue(forKey: notify)
    }

    public func changeDictionaryObservation(from: [String: NSObjectProtocol]?, to: [String: NSObjectProtocol]?, blocks: [String: KVONotificationBlock?]) {
        var from = from ?? [String: NSObjectProtocol]()
        let to = to ?? [String: NSObjectProtocol]()
        for (key, newValue) in to {
            let old = from[key]
            if old !== newValue {
                for (keyPath, block) in blocks {
                    if let block = block {
                        changeObservation(from: old, to: newValue, keyPath: keyPath, block: block)
                    }
                }
            }
            from.removeValue(forKey: key)
        }
        for (_, old) in from {
            for (keyPath, _) in blocks {
                for (keyPath, block) in blocks {
                    if let block = block {
                        changeObservation(from: old, to: nil, keyPath: keyPath, block: block)
                    }
                }
            }
        }
    }
}
