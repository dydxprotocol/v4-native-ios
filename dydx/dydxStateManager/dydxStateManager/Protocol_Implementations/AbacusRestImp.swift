//
//  AbacusRestImp.swift
//  dydxStateManager
//
//  Created by John Huang on 7/17/23.
//

import Foundation
import Abacus
import Utilities

final public class AbacusRestImp: Abacus.RestProtocol {
    public typealias RestCallback = (String?, KotlinInt, String?) -> Void

    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid

    private var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }()

    public func delete(url: String, headers: [String: String]?, callback: @escaping RestCallback) {
        processRest(url: url, headers: headers, body: nil, verb: "DELETE", callback: callback)
    }

    public func get(url: String, headers: [String: String]?, callback: @escaping RestCallback) {
        processRest(url: url, headers: headers, body: nil, verb: "GET", callback: callback)
    }

    public func post(url: String, headers: [String: String]?, body: String?, callback: @escaping RestCallback) {
        processRest(url: url, headers: headers, body: body, verb: "POST", callback: callback)
    }

    public func put(url: String, headers: [String: String]?, body: String?, callback: @escaping RestCallback) {
        processRest(url: url, headers: headers, body: body, verb: "PUT", callback: callback)
    }

    private func processRest(url: String, headers: [String: String]?, body: String?, verb: String, callback: @escaping RestCallback) {
        guard let url = URL(string: url) else {
            Console.shared.log("AbacusRestImp: invalid url \(url)")
            callback(nil, 0, nil)
            return
        }

        var request: URLRequest = urlRequest(url: url, verb: verb)
        request.allHTTPHeaderFields = headers
        if let body = body {
            request.httpBody = body.data(using: .utf8)
        }
        run(request: request, completionHandler: callback)
    }

    private func urlRequest(url: URL, verb: String) -> URLRequest {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = verb
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        return request
    }

    private func run(request: URLRequest, completionHandler: @escaping RestCallback) {
        beginBackgroundTask()
        Console.shared.log("AbacusRestImp Requesting \(request.url!.absoluteURL)")
        session.dataTask(with: request) {  [weak self] (raw: Data?, response: URLResponse?, _: Swift.Error?) in
            Console.shared.log("AbacusRestImp Receiving \(request.url!.absoluteURL)")
            self?.endBackgroundTask()
            DispatchQueue.main.async {
                guard let response = response as? HTTPURLResponse else {
                    completionHandler(nil, KotlinInt(integerLiteral: 0), nil)
                    return
                }
                var headers = [String: Any]()
                for key in response.allHeaderFields.keys {
                    if let key = key as? String, let value = response.value(forHTTPHeaderField: key) {
                        headers[key] = value
                    }
                }
                let headersJsonString = headers.jsonString
                let code = response.statusCode
                if let raw = raw, let text = String(data: raw, encoding: .utf8) {
                    completionHandler(text, KotlinInt(integerLiteral: code), headersJsonString)
                } else {
                    completionHandler(nil, KotlinInt(integerLiteral: code), headersJsonString)
                }
            }
        }.resume()
    }

    private func beginBackgroundTask() {
        if backgroundTaskId == .invalid {
            backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
        }
    }

    private func endBackgroundTask() {
        if backgroundTaskId != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            backgroundTaskId = .invalid
        }
    }
}
