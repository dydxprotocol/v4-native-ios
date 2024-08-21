//
//  DataLocalizer.swift
//  Utilities
//
//  Created by Qiang Huang on 5/22/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Foundation
import Combine

public protocol DataLocalizerProtocol {
    var language: String? { get }
    var languagePublisher: AnyPublisher<String?, Never> { get }
    func setLanguage(language: String, completed: @escaping (_ successful: Bool)-> Void)
    func localize(path: String, params: [String: String]?) -> String?
}

public class DataLocalizer {
    static public var shared: DataLocalizerProtocol?

    static public func localize(path: String, params: [String: String]? = nil) -> String {
        Self.shared?.localize(path: path, params: params) ?? path.lastPathComponent.pathExtension
    }
}
