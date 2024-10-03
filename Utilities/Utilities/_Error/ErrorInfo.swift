//
//  ErrorAlert.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 9/9/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public typealias ErrorActionHandler = () -> Void

@objc public class ErrorAction: NSObject {
    public var text: String
    public var handler: ErrorActionHandler

    public init(text: String, handler: @escaping ErrorActionHandler) {
        self.text = text
        self.handler = handler
        super.init()
    }

    @IBAction public func action(_ sender: Any?) {
        handler()
    }
}

@objc public enum EInfoType: Int {
    case info
    case wait
    case error
    case warning
    case success
}

public struct ErrorInfoData {
    public var title: String?
    public var message: String?
    public var type: EInfoType?
    public var error: Error?
    public var time: Double?
    public var actions: [ErrorAction]?
}

public protocol ErrorInfoProtocol: NSObjectProtocol {
    var appState: AppState? { get set }
    var pending: ErrorInfoData? { get set }

    func info(data: ErrorInfoData)
}

public extension ErrorInfoProtocol where Self: NSObject & CombineObserving {
    func didSetAppState(oldValue: AppState?) {
        changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) {[weak self] _, _, _, _ in
            if self?.appState?.background == false, let pending = self?.pending {
                self?.info(data: pending)
                self?.pending = nil
            }
        }
    }
}

public extension ErrorInfoProtocol {
    func info(title: String?, message: String?, error: Error?) {
        info(title: title, message: message, type: nil, error: error, time: 3.0)
    }

    func info(title: String?, message: String?, error: Error?, time: Double?) {
        info(title: title, message: message, type: nil, error: error, time: time, actions: nil)
    }

    func info(title: String?, message: String?, error: Error?, actions: [ErrorAction]?) {
        info(title: title, message: message, type: nil, error: error, time: 3.0, actions: actions)
    }

    func info(title: String?, message: String?, type: EInfoType?, error: Error?) {
        info(title: title, message: message, type: type, error: error, time: 3.0)
    }

    func info(title: String?, message: String?, type: EInfoType?, error: Error?, time: Double?) {
        info(title: title, message: message, type: type, error: error, time: time, actions: nil)
    }

    func info(title: String?, message: String?, type: EInfoType?, error: Error?, actions: [ErrorAction]?) {
        info(title: title, message: message, type: type, error: error, time: 3.0, actions: actions)
    }

    func info(title: String?, message: String?, type: EInfoType?, error: Error?, time: Double?, actions: [ErrorAction]?) {
        var message = message
        if message == nil, let errors = (error as? NSError)?.userInfo["errors"] as? [[String: String]], let msg = errors.first?["msg"] {
            message = trim(message: msg)
        }

        process(data: ErrorInfoData(title: title, message: message, type: type, error: error, time: time, actions: actions))
    }

    private func trim(message: String) -> String {
        return message.components(separatedBy: "(error=").first?.trim() ?? message
    }

    func process(data: ErrorInfoData) {
        if appState?.background == false {
            info(data: data)
        } else {
            pending = data
        }
    }

    func type(type: EInfoType?, error: Error?) -> EInfoType {
        if let type = type {
            return type
        } else {
            if let error = error {
                let nsError = error as NSError
                if nsError.code != 0 {
                    return .error
                } else {
                    return .info
                }
            } else {
                return .info
            }
        }
    }

    func message(message: String?, error: Error?) -> String? {
        if let message = message {
            return message
        } else {
            if let error = error {
                let nsError = error as NSError
                var text: String?
                if let description = nsError.userInfo["description"] as? String {
                    text = description
                } else if let message = nsError.userInfo["message"] as? String {
                    text = message
                } else if let msg = nsError.userInfo["msg"] as? String {
                    text = msg
                } else if let error = nsError.userInfo["error"] as? [String: Any] {
                    text = error["msg"] as? String ?? error["message"] as? String
                }
                return text ?? error.localizedDescription
            }
            return nil
        }
    }
}

public class ErrorInfo {
    public static var shared: ErrorInfoProtocol? {
        didSet {
            shared?.appState = AppState.shared
        }
    }
}

@objc public class ErrorInfoSwitcher: NSObject {
    public static func switcher(errorInfo: ErrorInfoProtocol) -> ErrorInfoSwitcher {
        let switcher = ErrorInfoSwitcher()
        switcher.errorInfo = errorInfo
        return switcher
    }

    private var errorInfo: ErrorInfoProtocol? {
        didSet {
            if errorInfo !== oldValue {
                previous = ErrorInfo.shared
                ErrorInfo.shared = errorInfo
            }
        }
    }

    private var previous: ErrorInfoProtocol?

    deinit {
        if let previous = previous {
            ErrorInfo.shared = previous
        }
    }
}
