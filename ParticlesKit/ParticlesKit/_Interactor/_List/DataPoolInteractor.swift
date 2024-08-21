//
//  DataPoolInteractor.swift
//  InteractorLib
//
//  Created by John Huang on 11/10/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

@objc open class DataPoolInteractor: LocalJsonCacheInteractor {
    @IBInspectable open var autoReload: Bool = false {
        didSet {
            didSetAutoReload(oldValue: oldValue)
        }
    }

    @objc open dynamic var appState: AppState? {
        didSet {
            didSetAppState(oldValue: oldValue)
        }
    }

    @objc open dynamic var network: NetworkConnection? {
        didSet {
            didSetNetwork(oldValue: oldValue)
        }
    }

    @objc open dynamic var data: [String: ModelObjectProtocol]? {
        didSet {
            didSetData(oldValue: oldValue)
        }
    }

    @objc open dynamic var transformed: [String: ModelObjectProtocol]? {
        didSet {
            didSetTransformed(oldValue: oldValue)
        }
    }

    @objc open dynamic var sequence: [ModelObjectProtocol]? {
        didSet {
            didSetSequence(oldValue: oldValue)
        }
    }

    @objc open dynamic var sequenceTransformed: [ModelObjectProtocol]? {
        didSet {
            didSetSequenceTransformed(oldValue: oldValue)
        }
    }

    public var sequential: Bool {
        return false
    }

    @objc open dynamic var isLoading: Bool = false

    internal var saveDebouncer: Debouncer = Debouncer()
    internal var isLoadingDebouncer: Debouncer = Debouncer()

    open var lastLoadTime: Date?

    open func didSetAutoReload(oldValue: Bool) {
        if autoReload != oldValue {
            if autoReload {
                appState = AppState.shared
                network = NetworkConnection.shared
            } else {
                appState = nil
                network = nil
            }
        }
    }

    override open func loadSelf() {
        isLoading = true
        super.loadSelf()
    }

    open func didSetAppState(oldValue: AppState?) {
        changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) { [weak self] _, _, _, animated in
            if animated {
                self?.maybeAutoReload()
            }
        }
    }

    open func didSetNetwork(oldValue: NetworkConnection?) {
        changeObservation(from: oldValue, to: network, keyPath: #keyPath(NetworkConnection.connected)) { [weak self] _, _, _, animated in
            if animated {
                self?.maybeAutoReload()
            }
        }
    }

    private func maybeAutoReload() {
        if autoReload, appState?.background == false, network?.connected == true {
            if let lastLoadTime = lastLoadTime {
                if Date().timeIntervalSince(lastLoadTime) > 30.0 {
                    doAutoReload()
                }
            } else {
                doAutoReload()
            }
        }
    }

    open func doAutoReload() {
        load()
    }

    open func didSetData(oldValue: [String: ModelObjectProtocol]?) {
        transformed = transform(data: data)
        sequence = sequence(data: data)
    }

    open func didSetSequence(oldValue: [ModelObjectProtocol]?) {
        sequenceTransformed = transform(sequence: sequence)
    }

    open func transform(data: [String: ModelObjectProtocol]?) -> [String: ModelObjectProtocol]? {
        return data
    }

    open func transform(sequence: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return sequence
    }

    open func didSetTransformed(oldValue: [String: ModelObjectProtocol]?) {
    }

    open func didSetSequenceTransformed(oldValue: [ModelObjectProtocol]?) {
    }

    override open func receive(io: IOProtocol?, object: Any?, loadTime: Date?, error: Error?) {
        if let error = error {
            if (error as NSError).code == 403 || (error as NSError).code == 204 {
                receive(io: io, parsedSequence: nil)
            } else {
                let temp = data
                data = temp
            }
        } else {
            if let entities = object as? [ModelObjectProtocol] {
                receive(io: io, parsedSequence: entities)
            } else {
                receive(io: io, parsedSequence: nil)
            }
            lastLoadTime = Date()
        }
        checkLoading()
    }

//    open func receive(io: IOProtocol?, parsedData: [String: ModelObjectProtocol]?) {
//        data = parsedData
//        save()
//    }

    open func receive(io: IOProtocol?, parsedSequence: [ModelObjectProtocol]?) {
        let sequence = sequence(sequence: ordered(sequence: parsedSequence))
        data = map(sequence: sequence)
        self.sequence = sequence
        save()
    }

    open func sequence(sequence: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return sequence
    }

    open func ordered(sequence: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return sequence
    }

    open func sequence(data: [String: ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        if let data = data {
            return Array(data.values)
        } else {
            return nil
        }
    }

    open func map(sequence: [ModelObjectProtocol]?) -> [String: ModelObjectProtocol]? {
        if let entities = sequence {
            var parsed = [String: ModelObjectProtocol]()
            for entity in entities {
                if let key = entity.key {
                    if let key = key {
                        parsed[key] = entity
                    }
                }
            }
            return parsed
        } else {
            return nil
        }
    }

    override open func save() {
        if let handler = saveDebouncer.debounce() {
            handler.run({ [weak self] in
                self?.loader?.save(object: self?.sequence)
            }, delay: 1)
        }
    }

    open func checkLoading() {
        isLoadingDebouncer.debounce()?.run({ [weak self] in
            self?.reallyCheckLoading()
        }, delay: 0.01)
    }

    open func reallyCheckLoading() {
        isLoading = loader?.isLoading ?? false
    }
}

@objc public protocol RangeProtocol: NSObjectProtocol {
    var low: NSNumber? { get set }
    var high: NSNumber? { get set }

    func lowOf(obj: ModelObjectProtocol) -> NSNumber?
    func highOf(obj: ModelObjectProtocol) -> NSNumber?
}

extension RangeProtocol {
    public func low(number1: NSNumber?, number2: NSNumber?) -> NSNumber? {
        if let number1 = number1 {
            if let number2 = number2 {
                return (number2.doubleValue < number1.doubleValue) ? number2 : number1
            } else {
                return number1
            }
        } else {
            return number2
        }
    }

    public func high(number1: NSNumber?, number2: NSNumber?) -> NSNumber? {
        if let number1 = number1 {
            if let number2 = number2 {
                return (number2.doubleValue > number1.doubleValue) ? number2 : number1
            } else {
                return number1
            }
        } else {
            return number2
        }
    }

    public func range(debouncer: Debouncer, data: [String: ModelObjectProtocol]?) {
        if let data = data {
            var low = low
            var high = high
            debouncer.debounce()?.run(background: { [weak self] in
                if let self = self {
                    for (_, value) in data {
                        low = self.low(number1: low, number2: self.lowOf(obj: value))
                        high = self.high(number1: high, number2: self.highOf(obj: value))
                    }
                }
            }, final: { [weak self] in
                self?.low = low
                self?.high = high
            }, delay: 0.0)
        }
    }
}
