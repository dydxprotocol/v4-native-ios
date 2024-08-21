//
//  WebSocketApi.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 3/5/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Utilities

public typealias WebSocketReceiveHandler = (_ meta: [String: Any]?, _ received: Any, _ hasData: Bool) -> Void
public typealias WebSocketSubscribingDataProvider = () -> Any?
public typealias WebSocketUnsubscribingDataProvider = () -> [String: Any]?

public class WebSocketHook {
    public var hasData: Bool = false
    public var subscribeData: WebSocketSubscribingDataProvider?
    public var unsubscribeData: WebSocketUnsubscribingDataProvider?
    public var handler: WebSocketReceiveHandler

    init(subscribeData: WebSocketSubscribingDataProvider?, unsubscribeData: WebSocketUnsubscribingDataProvider?, handler: @escaping WebSocketReceiveHandler) {
        self.subscribeData = subscribeData
        self.unsubscribeData = unsubscribeData
        self.handler = handler
    }
}

@available(iOS 13.0, *)
@objc open class WebSocketApi: HttpApi {
    private var networkStatus: NetworkConnection? {
        didSet {
            changeObservation(from: oldValue, to: networkStatus, keyPath: #keyPath(NetworkConnection.connected)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.running = self.shouldRun()
                }
            }
        }
    }

    override public var background: Bool {
        didSet {
            if background != oldValue {
                running = shouldRun()
            }
        }
    }

    public var hooks: [String: WebSocketHook] = [:]

    private var url: URL? {
        didSet {
            if url != oldValue {
                reset()
            }
        }
    }

    private var dataTask: URLSessionWebSocketTask? {
        didSet {
            if dataTask !== oldValue {
                if dataTask != nil {
                    dataTask?.resume()
                    receive()
                } else {
                    connected = false
                }
            }
        }
    }

    private var connected: Bool = false {
        didSet {
            if connected != oldValue {
                if connected {
//                    sendSubscriptions()
                }
                pingTimer = connected ? ping() : nil
            }
        }
    }

    @objc public dynamic var running: Bool = false {
        didSet {
            if running != oldValue {
                for (_, hook) in hooks {
                    hook.hasData = false
                }
                if running {
                    if let url = url {
                        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
                        let dataTask = urlSession.webSocketTask(with: url)
                        dataTask.resume()
                        self.dataTask = dataTask
                    } else {
                        running = false
                    }
                } else {
                    Console.shared.log("Websocket: Task cancelled")
                    dataTask?.cancel()
                    dataTask = nil
                }
            }
        }
    }

    private var pingTimer: Timer? {
        didSet {
            if pingTimer !== oldValue {
                oldValue?.invalidate()
            }
        }
    }

    deinit {
        running = false
    }

    public func load(path: String, params: [String: Any]?) {
        if networkStatus == nil {
            networkStatus = NetworkConnection.shared
        }
        if let server = server {
            let pathAndParams = url(server: server, path: path, params: params)
            if pathAndParams.urlPath.contains("{") {
                // unresolved params
                url = nil
            } else {
                url = url(path: pathAndParams.urlPath, params: pathAndParams.paramStrings)
            }
        }
    }

    public func subscribe(channel: String, subscribeData: WebSocketSubscribingDataProvider?, unsubscribeData: WebSocketUnsubscribingDataProvider?, hook: @escaping WebSocketReceiveHandler) {
        hooks[channel] = WebSocketHook(subscribeData: subscribeData, unsubscribeData: unsubscribeData, handler: hook)
        if running {
            if connected {
                if let subscribeData = subscribeData?() {
                    send(data: subscribeData)
                }
            }
        } else {
            running = shouldRun()
        }
    }

    public func unsubscribe(channel: String) {
        if let hook = hooks[channel] {
            if let unsubscribeData = hook.unsubscribeData?() {
                send(data: unsubscribeData)
            }
        }
        hooks[channel] = nil
        running = shouldRun()
    }

    private func shouldRun() -> Bool {
        return !background && (networkStatus?.connected?.boolValue ?? false) && hooks.count != 0
    }

    private func websocket() -> URLSessionWebSocketTask? {
        if let url = url {
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            return urlSession.webSocketTask(with: url)
        }
        return nil
    }

    public func sendSubscriptions() {
        for (_, hook) in hooks {
            send(data: hook.subscribeData?())
        }
    }

    public func send(data: Any?) {
        if let string = data as? String {
            let message = URLSessionWebSocketTask.Message.string(string)
            dataTask?.send(message, completionHandler: { [weak self] error in
                if error != nil {
                    self?.reset()
                }
            })
        } else if let data = data as? Data {
            let message = URLSessionWebSocketTask.Message.data(data)
            dataTask?.send(message, completionHandler: { [weak self] error in
                if error != nil {
                    self?.reset()
                }
            })
        } else if let data = data as? [String: Any] {
            if let string = string(json: data) {
                let message = URLSessionWebSocketTask.Message.string(string)
                dataTask?.send(message, completionHandler: { [weak self] error in
                    if error != nil {
                        self?.reset()
                    }
                })
            }
        }
    }

    private func reset() {
        running = false
        running = shouldRun()
    }

    private func receive() {
        dataTask?.receive { [weak self] result in
            if let self = self {
                switch result {
                case let .failure(error):
                    ErrorLogging.shared?.log(error)
                    self.reset()

                case let .success(message):
                    switch message {
                    case let .string(text):
//                        Console.shared.log("Websocket: Received text message: \(text)")
                        self.dispatch(text: text)

                    case let .data(data):
//                        Console.shared.log("Websocket: Received binary message: \(data)")
                        self.dispatch(data: data)

                    @unknown default:
//                        Console.shared.log("Websocket: Unknown error")
                        break
                    }
                    self.receive()
                }
            }
        }
    }

    open func dispatch(text: String) {
    }

    open func dispatch(data: Data) {
    }

    private func ping() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 25, repeats: true) { [weak self] _ in
            self?.dataTask?.sendPing { error in
                if let error = error {
                    Console.shared.log("Ping failed: \(error)")
                }
            }
        }
    }

    private func string(json: Any?) -> String? {
        if let json = json {
            if let data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
                return String(data: data, encoding: String.Encoding.utf8)
            }
        }
        return nil
    }
}

@available(iOS 13.0, *)
extension WebSocketApi: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        connected = true
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        running = false
    }
}
