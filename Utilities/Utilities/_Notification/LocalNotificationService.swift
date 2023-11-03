//
//  LocalNotificationService.swift
//  Utilities
//
//  Created by Qiang Huang on 11/4/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

public class LocalNotificationMessage: NSObject {
    public var title: String
    public var subtitle: String?
    public var text: String?
    public var link: String?
    public var delay: TimeInterval?

    public init(title: String, subtitle: String? = nil, text: String? = nil, link: String? = nil, delay: TimeInterval? = nil) {
        self.title = title
        super.init()
        self.subtitle = subtitle
        self.text = text
        self.link = link
        self.delay = delay
    }
}

public protocol LocalNotificationProtocol: NSObjectProtocol {
    var background: LocalNotificationMessage? { get set }
    func send(message: LocalNotificationMessage)
}

public class LocalNotificationService {
    public static var shared: LocalNotificationProtocol?
}
