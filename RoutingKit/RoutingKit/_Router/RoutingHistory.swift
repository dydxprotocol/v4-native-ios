//
//  RoutingHistory.swift
//  RoutingKit
//
//  Created by Qiang Huang on 11/24/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation
import Utilities

public class RoutingEvent: NSObject {
    public var request: RoutingRequest?
    public weak var destination: NavigableProtocol?
}

public final class RoutingHistory: NSObject, SingletonProtocol {
    public static var shared: RoutingHistory = {
        RoutingHistory()
    }()

    public var events: [RoutingEvent] = [RoutingEvent]()
    public var debouncer: Debouncer = Debouncer()

    public var persistTag: String {
        return "\(String(describing: type(of: self))).persist"
    }

    public var persistDataFile: String? {
        return FolderService.shared?.documents()?.stringByAppendingPathComponent(path: "\(persistTag).data.json")
    }

    public func record(destination: NavigableProtocol) {
        if !makeLast(destination: destination) {
            if let history = destination.history {
                if history != nil {
                    let event = RoutingEvent()
                    event.destination = destination
                    event.request = history
                    events.append(event)
                    save()
                }
            }
        }
    }

    public func modifyEvent(destination: NavigableProtocol, with request: RoutingRequest) {
        if let event = events.first(where: { (event: RoutingEvent) -> Bool in
            event.destination === destination
        }) {
            event.request = request
            save()
        }
    }

    public func makeLast(destination: NavigableProtocol) -> Bool {
        if let index = events.firstIndex(where: { (event: RoutingEvent) -> Bool in
            event.destination === destination
        }) {
            if let history = destination.history {
                if history != nil {
                    events[index].request = history
                }
            }
            events = Array(events.prefix(through: index))
            save()
            return true
        }
        return false
    }

    public func remove(destination: NavigableProtocol) {
        if let index = events.firstIndex(where: { (event: RoutingEvent) -> Bool in
            event.destination === destination
        }) {
            events = Array(events.prefix(upTo: index))
            save()
        }
    }

    public func save() {
        if let handler = debouncer.debounce() {
            handler.run({ [weak self] in
                self?.write()
            }, delay: 0.5)
        }
    }

    public func write() {
        DispatchQueue.global().async { [weak self] in
            if let self = self, let persistDataFile = self.persistDataFile {
                let paths = self.events.compactMap({ (event) -> String? in
                    if let path = event.request?.path {
                        if let params = event.request?.params {
                            let lines = params.map({ (arg0) -> String in
                                let (key, value) = arg0
                                return "\(key)=\(value)"
                            })
                            return "\(path)?\(lines.joined(separator: "&"))"
                        } else {
                            return path
                        }
                    }
                    return nil
                })
                do {
                    let json = try JSONSerialization.data(withJSONObject: paths, options: .prettyPrinted)
                    try json.write(to: URL(fileURLWithPath: persistDataFile))
                } catch {
                }
            }
        }
    }

    public func history() -> [RoutingRequest]? {
        if let persistDataFile = self.persistDataFile, let lines = JsonLoader.load(file: persistDataFile) as? [String] {
            return lines.compactMap({ (line) -> RoutingRequest? in
                let pathAndParams = line.components(separatedBy: "?")
                switch pathAndParams.count {
                case 1:
                    return RoutingRequest(path: line)

                case 2:
                    if let path = pathAndParams.first, let paramsString = pathAndParams.last {
                        let params = paramsString.components(separatedBy: "&")
                        var requestParams: [String: Any] = [:]
                        for param in params {
                            let keyAndValues = param.components(separatedBy: "=")
                            if keyAndValues.count == 2 {
                                if let key = keyAndValues.first, let value = keyAndValues.last {
                                    requestParams[key] = value
                                }
                            }
                        }
                        return RoutingRequest(path: path, params: requestParams)
                    } else {
                        return nil
                    }

                default:
                    return nil
                }
            })
        }
        return nil
    }
}
