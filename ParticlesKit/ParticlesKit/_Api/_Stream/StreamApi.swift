//
//  StreamApi.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 10/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Utilities
import Combine

public typealias StreamingReadFunction = (_ messages: [String]) -> Void
public typealias DisconnectFuction = (_ error: Error?) -> Void

@objc open class StreamApi: NSObject, CombineObserving {
    public var cancellableMap = [AnyKeyPath : AnyCancellable]()
    
    private var appState: AppState? {
        didSet {
            changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) { [weak self] _, _, _, animated in
                self?.background = self?.appState?.background ?? false
            }
        }
    }

    private var server: String?
    private var port: Int?
    private var reading: StreamingReadFunction?
    private var disconnecting: DisconnectFuction?

    public lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.shouldUseExtendedBackgroundIdleMode = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    @objc open dynamic var background: Bool = false {
        willSet {
            if background != newValue {
                if newValue {
                    beginBackgroundTask()
                } else {
                    endBackgroundTask()
                }
            }
        }
    }

    #if _iOS || _tvOS
        private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    #endif

    @objc open dynamic var task: URLSessionStreamTask? {
        didSet {
            if task !== oldValue {
                isConnected = (task != nil)
                if task != nil {
                    read()
                }
            }
        }
    }

    @objc public dynamic var isConnected: Bool = false
    private var leftover: String?


    override public init() {
        super.init()
        DispatchQueue.main.async {[weak self] in
            self?.background = self?.appState?.background ?? false
        }
    }

    public init(server: String?, port: Int) {
        super.init()
        self.server = server
        self.port = port
        DispatchQueue.main.async {[weak self] in
            self?.background = self?.appState?.background ?? false
        }
    }

    public func connect(server: String, port: Int, reading: StreamingReadFunction?, disconnecting: DisconnectFuction?) {
        self.server = server
        self.port = port
        connect(reading: reading, disconnecting: disconnecting)
    }

    open func connect(reading: StreamingReadFunction?, disconnecting: DisconnectFuction?) {
        self.reading = reading
        self.disconnecting = disconnecting

        if let server = server, let port = port {
            let task = session.streamTask(withHostName: server, port: port)
            task.resume()
            self.task = task
        } else {
            task = nil
        }
    }

    open func disconnect() {
        task?.closeWrite()
        task?.closeRead()
        task = nil
    }

    private func read() {
        task?.readData(ofMinLength: 0, maxLength: 16000, timeout: 0) { [weak self] data, _, _ in
            if let self = self {
                DispatchQueue.main.async { [weak self] in
                    if let self = self {
                        if let data = data, let message = String(data: data, encoding: .utf8) {
                            #if DEBUG
                                let starting = message.prefix(32)
                                Console.shared.log("Edge:Start: \(starting)")
                                let ending = message.suffix(32)
                                Console.shared.log("Edge:End: \(ending)")
                            #endif
                            let lines = message.components(separatedBy: "\r\n")
                            var messages = [String]()
                            for index in 0 ..< lines.count {
                                let line = lines[index]
                                if index == 0 {
                                    if let leftover = self.leftover {
                                        messages.append("\(leftover)\(line)")
                                        self.leftover = nil
                                    } else {
                                        messages.append(String(line))
                                    }
                                } else if index == lines.count - 1 {
                                    self.leftover = String(line)
                                } else {
                                    messages.append(String(line))
                                }
                            }
                            self.reading?(messages)
                        }
                        self.read()
                    }
                }
            }
        }
    }

    open func send(message: String) {
        task?.write(message.data(using: .utf8)!, timeout: 0) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    self?.disconnecting?(error)
                }
                Console.shared.log("Failed to send: \(String(describing: error))")
            } else {
                Console.shared.log("Sent!")
            }
        }
    }

    private func beginBackgroundTask() {
        #if _iOS || _tvOS
            if backgroundTaskId == .invalid {
                backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
                    if let self = self {
                        self.task?.suspend()
//                        self.task?.closeRead()
//                        self.task?.closeWrite()
//                        self.task = nil
                        self.endBackgroundTask()
                    }
                }
            }
        #endif
    }

    private func endBackgroundTask() {
        #if _iOS || _tvOS
            if backgroundTaskId != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
                backgroundTaskId = .invalid
                task?.resume()
            }
        #endif
    }
}

extension StreamApi: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.disconnect()
            self?.disconnecting?(error)
        }
    }
}
