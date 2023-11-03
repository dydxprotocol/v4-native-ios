//
//  LocalJsonCacheInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 11/10/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

@objc open class LocalJsonCacheInteractor: BaseInteractor, LocalCacheProtocol {
    
    @objc open var key: String?
    open var defaultJson: String?
    private var _loader: LoaderProtocol?
    public var loader: LoaderProtocol? {
        if _loader == nil {
            _loader = createLoader()
        }
        return _loader
    }

    public var path: String? {
        if let key = key {
            return "\(String(describing: type(of: self))).persist.\(key)"
        }
        return nil
    }

    open var loadingParams: [String: Any]? {
        return nil
    }
    
    private var loadDebouncer = Debouncer()

    override public init() {
        super.init()
    }

    public init(key: String? = nil, default defaultJson: String? = nil) {
        super.init()
        self.key = key
        self.defaultJson = defaultJson
        load()
    }

    open func createLoader() -> LoaderProtocol? {
        return nil
    }

    open func load() {
        loadDebouncer.debounce()?.run({[weak self] in
            self?.loadSelf()
        }, delay: nil)
    }
    
    open func loadSelf() {
        loader?.load(params: loadingParams, completion: { [weak self] (io: IOProtocol?, object: Any?, loadTime: Date?, error: Error?) in
            if error == nil {
                self?.receive(io:io, object: object, loadTime: loadTime, error: error)
            } else {
                self?.loadDefaults()
            }
        })
    }

    open func loadDefaults() {
        if let defaultJson = defaultJson, let defaultPayload = JsonLoader.load(bundles: Bundle.particles, fileName: defaultJson) as? [String: Any] {
            let entity = entity(from: defaultPayload)
            (entity as? ParsingProtocol)?.parse?(dictionary: defaultPayload)
            receive(io: nil, object: entity, loadTime: nil, error: nil)
        } else {
           //receive(io: nil, object: nil, loadTime: nil, error: nil)
        }
    }

    open func entity(from data: [String: Any]?) -> ModelObjectProtocol? {
        return nil
    }

    open func receive(io: IOProtocol?, object: Any?, loadTime: Date?, error: Error?) {
    }

    open func save() {
    }
}
