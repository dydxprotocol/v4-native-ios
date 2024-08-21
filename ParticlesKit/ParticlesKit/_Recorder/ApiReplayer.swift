//
//  ApiReplayer.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 11/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Utilities

public enum ApiReplayMode {
    case normal
    case recording
    case replay
}

public protocol ApiReplayerProtocol {
    var mode: ApiReplayMode { get }
    func replay(urlPath: String, params: [String]?) -> Any?
    func record(urlPath: String, params: [String]?, data: Any?)
}

public class ApiReplayer {
    public static var shared: ApiReplayerProtocol?
}

public class JsonApiReplayer: NSObject, ApiReplayerProtocol {
    public var path: String?
    public var key: String? = "default"
    public var recording: [String: Any]?
    public var debouncer: Debouncer = Debouncer()

    public var mode: ApiReplayMode {
        if let testString = parser.asString(DebugSettings.shared?.debug?["integration_test"]) {
            if testString == "r" {
                return .recording
            } else if testString == "t" {
                return .replay
            }
        } else if let modeString = parser.asString(DebugSettings.shared?.debug?["api_replay"]) {
            if modeString == "r" {
                return .recording
            } else if modeString == "p" {
                return .replay
            }
        }
        return .normal
    }

    public var persistTag: String? {
        if let key = key {
            return "\(String(describing: type(of: self))).persist.\(key)"
        }
        return nil
    }

    public var persistDataFile: String? {
        if let persistTag = persistTag {
            if let path = path ?? FolderService.shared?.documents() {
                _ = Directory.ensure(path)
                return path.stringByAppendingPathComponent(path: "\(persistTag).data.json")
            }
        }
        return nil
    }

    public init(path: String? = nil) {
        super.init()
        self.path = path
        load()
    }

    private func uniqueUrl(urlPath: String, params: [String]?) -> String {
        let params = params?.sorted(by: { (string1, string2) -> Bool in
            string1 < string2
        })
        var urlPath = urlPath
        if let params = params {
            if params.count > 0 {
                urlPath = urlPath + "?" + params.joined(separator: "&")
            }
        }
        return urlPath
    }

    public func replay(urlPath: String, params: [String]?) -> Any? {
        if mode == .replay {
            let url = uniqueUrl(urlPath: urlPath, params: params)
            return recording?[url]
        }
        return nil
    }

    public func record(urlPath: String, params: [String]?, data: Any?) {
        if mode == .replay || mode == .recording {
            if recording == nil {
                recording = [:]
            }
            let url = uniqueUrl(urlPath: urlPath, params: params)
            recording?[url] = data

            if let handler = debouncer.debounce() {
                handler.run({ [weak self] in
                    self?.save()
                }, delay: 0.5)
            }
        }
    }

    private func save() {
        if let persistDataFile = self.persistDataFile, let persist = recording {
            JsonWriter.write(persist, to: persistDataFile)
        }
    }

    open func load() {
        if let persistDataFile = self.persistDataFile, let recording = JsonLoader.load(file: persistDataFile) as? [String: Any] {
            self.recording = recording
        }
    }
}
