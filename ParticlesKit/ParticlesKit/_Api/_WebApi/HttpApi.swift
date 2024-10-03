//
//  HttpApi.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 8/13/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities
import Combine

public enum HttpVerb: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

@objc open class HttpApi: NSObject, CombineObserving {
    public var cancellableMap = [AnyKeyPath: AnyCancellable]()

    private var appState: AppState? {
        didSet {
            changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) {[weak self] _, _, _, _ in
                self?.background = self?.appState?.background ?? false
            }
        }
    }

    @objc public dynamic var background: Bool = false
    public var endpointResolver: EndpointResolverProtocol?
    public var server: String?
    public var status: LoadingStatus? {
        didSet {
            if status !== oldValue {
//                oldValue?.minus()
//                status?.plus()
            }
        }
    }

    public var requestInjections: [WebApiRequestInjectionProtocol]?
    public var responseInjections: [WebApiResponseInjectionProtocol]?

    override public init() {
        super.init()
        DispatchQueue.main.async { [weak self] in
            self?.appState = AppState.shared
        }
    }

    public init(server: String?) {
        super.init()
        self.server = server
        DispatchQueue.main.async { [weak self] in
            self?.appState = AppState.shared
        }
    }

    public init(endpointResolver: EndpointResolverProtocol?) {
        super.init()
        self.endpointResolver = endpointResolver
        server = endpointResolver?.host
        DispatchQueue.main.async { [weak self] in
            self?.appState = AppState.shared
        }
    }

    deinit {
        status = nil
    }

    public func request(verb: HttpVerb, url: URL, body: Any?, completion: @escaping (_ request: URLRequest) -> Void) {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = verb.rawValue
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if let body = body {
            if let bodyText = try? JSONSerialization.data(withJSONObject: body, options: []) {
//                let string = String(data: bodyText, encoding: String.Encoding.utf8)
//                Console.shared.log("Post Body \(string)")
                request.httpBody = bodyText
            }
        }
        inject(request: request, verb: verb, index: 0) { /* [weak self] */ request in
            completion(request)
        }
    }

    public func inject(request: URLRequest, verb: HttpVerb, index: Int, completion: @escaping (_ request: URLRequest) -> Void) {
        if let injections = requestInjections, index < injections.count {
            let injection = injections[index]
            injection.inject(request: request, verb: verb) { [weak self] request in
                self?.inject(request: request, verb: verb, index: index + 1, completion: completion)
            }
        } else {
            completion(request)
        }
    }

    open func url(server: String, path: String, params: [String: Any]?) -> (urlPath: String, paramStrings: [String]?) {
        var urlPath = "\(server)\(path)"
        var paramStrings: [String]?
        if let paramsDictionary = params {
            var leftover = [String: Any]()
            for (key, value) in paramsDictionary {
                let marker = "{\(key)}"
                if urlPath.contains(marker) {
                    urlPath = urlPath.replacingOccurrences(of: marker, with: "\(value)")
                } else {
                    leftover[key] = value
                }
            }
            if leftover.count > 0 {
                paramStrings = [String]()
                for (key, value) in leftover {
                    // transform value into string
                    if value is String {
                        paramStrings?.append("\(key)=\(value)")
                    } else if let stringValue = parser.asString(value) {
                        paramStrings?.append("\(key)=\(stringValue)")
                    }
                }
            }
        }
        return (urlPath, paramStrings)
    }

    public func url(path: String, params: [String]?) -> URL? {
        var url = path
        if let params = params {
            if params.count > 0 {
                url = path + "?" + params.joined(separator: "&")
            }
        }
        if let encodedUrl = url.encodeUrl() {
            return URL(string: encodedUrl)
        }
        return nil
    }

    public func merge(_ params1: [String: Any]?, with params2: [String: Any]?) -> [String: Any] {
        var merged: [String: Any] = [:]
        if let params1 = params1 {
            merged.merge(params1) { (_, second) -> Any in
                second
            }
        }
        if let params2 = params2 {
            merged.merge(params2) { (_, second) -> Any in
                second
            }
        }
        return merged
    }

    open func result(data: Any?) -> Any? {
        return data
    }

    open func meta(data: Any?) -> Any? {
        return nil
    }
}
