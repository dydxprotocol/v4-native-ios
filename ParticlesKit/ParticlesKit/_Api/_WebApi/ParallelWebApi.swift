//
//  ParallelWebApi.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/29/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

open class ParallelWebApi<PagedWebApiClass, WebApiClass>: NSObject, IOProtocol where WebApiClass: WebApi, PagedWebApiClass: PagedWebApi<WebApiClass> {
    @objc public dynamic var isLoading: Bool = false

    public var priority: Int = 10

    public var limit: Int = 100 // items per page
    public var lanes: Int = 100
    public var total: Int?
    private var apis: [Int: PagedWebApiClass] = [Int: PagedWebApiClass]()
    private var responses: [Int: Any] = [:]
    private var completion: IOReadCompletionHandler?

    public required init(lanes: Int? = nil) {
        super.init()
        if let lanes = lanes {
            self.lanes = lanes
        }
    }

    public func load(path: String, params: [String: Any]?, completion: @escaping IOReadCompletionHandler) {
        apis.removeAll()
        responses.removeAll()
        self.completion = completion

        isLoading = true
        for i in 0 ... lanes {
            run(path: path, page: i, params: params)
        }
    }

    public func save(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
    }

    public func modify(path: String, params: [String: Any]?, data: Any?, completion: IOWriteCompletionHandler?) {
    }

    public func delete(path: String, params: [String: Any]?, completion: IODeleteCompletionHandler?) {
    }

    open func run(path: String, page: Int, params: [String: Any]?) {
        var pass = true
        if let total = total {
            if page * limit >= total {
                pass = false
            }
        }
        if pass {
            let api = PagedWebApiClass(page: page, limit: limit)
            api.load(path: path, params: params) { [weak self] (data: Any?, meta: Any?, _: Int, _: Error?) in
                if let self = self {
                    if let total = self.total(meta: meta) {
                        self.total = total
                    }
                    if let loaded = data as? [Any] {
                        if loaded.count != 0 {
                            self.responses[page] = loaded
                            self.run(path: path, page: api.page + self.lanes, params: params)
                        }
                    } else {
                        self.finishWhenDone()
                    }
                    self.apis.removeValue(forKey: api.page)
                }
            }
            apis[page] = api
        } else {
            finishWhenDone()
        }
    }

    open func total(meta: Any?) -> Int? {
        return nil
    }

    internal func finishWhenDone() {
        if let total = total {
            if responses.count * limit >= total {
                finish()
            }
        }
    }

    open func finish() {
        var completeResponses = [Any]()
        for i in 0 ..< responses.count {
            if let pagedResponses = responses[i] as? [Any] {
                completeResponses.append(contentsOf: pagedResponses)
            }
        }
        isLoading = false
        completion?(completeResponses, nil, priority, nil)
    }
}
