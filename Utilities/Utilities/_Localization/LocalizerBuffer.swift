//
//  LocalizationBuffer.swift
//  Utilities
//
//  Created by Qiang Huang on 11/24/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation
import Combine

public protocol LocalizerBufferProtocol {
    func localize(_ text: String?, to: String?)
}

public class LocalizerBuffer {
    public static var shared: LocalizerBufferProtocol?
}

public class DebugLocalizer: NSObject, LocalizerBufferProtocol, CombineObserving {
    public var cancellableMap = [AnyKeyPath : AnyCancellable]()
    
    private var appState: AppState? {
        didSet {
            changeObservation(from: oldValue, to: appState, keyPath: #keyPath(AppState.background)) {[weak self] observer, obj, change, animated in
                if self?.appState?.background ?? false {
                    self?.write()
                }
            }
        }
    }

    private var strings: [String: String] = [:]
    public func localize(_ text: String?, to: String?) {
        if let text = text?.trim() {
            strings[text] = to ?? text
        }
    }

    override public init() {
        super.init()
        DispatchQueue.main.async { [weak self] in
            self?.appState = AppState.shared
        }
    }

    private func write() {
        if let localized = FolderService.shared?.documents()?.stringByAppendingPathComponent(path: "Localizable.strings") {
            File.delete(localized)
            let mutable = NSMutableString()
            let keys = strings.keys.sorted()
            for key in keys {
                let value = strings[key] ?? key
                mutable.append("\"\(key)\" = \"\(value)\";\n")
            }
            do {
                try mutable.write(toFile: localized, atomically: true, encoding: String.Encoding.utf8.rawValue)
            } catch {
                // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            }
        }
    }
}
