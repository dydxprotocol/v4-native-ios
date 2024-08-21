//
//  HttpCall.swift
//  abacus.ios
//
//  Created by John Huang on 8/30/22.
//

import Abacus
import Foundation
import UIKit
import Utilities

struct HttpRequest {
    let host: String
    let path: String
    let port: KotlinInt?
    let params: [String]?
}

public class HttpCall: NSObject {
    public var url: String
    public var session: URLSession
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private var dataTask: URLSessionDataTask?

    public init(url: String, session: URLSession) {
        self.url = url
        self.session = session
        super.init()
    }

    public func request(verb: HttpVerb, headers: [String: String]?, body: Any?, completionHandler: @escaping (String?) -> Void) {
        if let url = URL(string: url) {
            var request: URLRequest = urlRequest(url: url, verb: method(verb: verb))
            if let headers = headers {
                request.allHTTPHeaderFields = headers
            }
            if let body = body as? String {
                request.httpBody = body.data(using: .utf8)
            }
            run(request: request, completionHandler: completionHandler)
        }
    }

    private func urlRequest(url: URL, verb: String) -> URLRequest {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = verb
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    public func run(request: URLRequest, completionHandler: @escaping (String?) -> Void) {
        beginBackgroundTask()
        Console.shared.log("Requesting \(request.url!.absoluteURL)")
        dataTask = session.dataTask(with: request) { [weak self] (raw: Data?, response: URLResponse?, _: Swift.Error?) in
            Console.shared.log("Receiving \(request.url!.absoluteURL)")
            self?.endBackgroundTask()
            DispatchQueue.main.async {
                if let raw = raw, request.url?.absoluteString != nil, let code = (response as? HTTPURLResponse)?.statusCode, let text = String(data: raw, encoding: .utf8), code >= 200 {
                    completionHandler(text)
                } else {
                    completionHandler(nil)
                }
            }
        }
        dataTask?.resume()
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

    private func method(verb: HttpVerb) -> String {
        switch verb {
        case .get:
            return "GET"

        case .post:
            return "POST"

        case .put:
            return "PUT"

        case .delete_:
            return "DELETE"

        default:
            return "GET"
        }
    }

    deinit {
        endBackgroundTask()
    }
}
