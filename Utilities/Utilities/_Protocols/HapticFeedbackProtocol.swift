//
//  HapticFeedbackProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 10/30/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Foundation

public enum ImpactLevel: Int {
    case low
    case medium
    case high
}

public enum NotificationType: Int {
    case success
    case warnng
    case error
}

public protocol HapticFeedbackProtocol {
    func prepareImpact(level: ImpactLevel)
    func prepareSelection()
    func prepareNotify(type: NotificationType)
    
    func impact(level: ImpactLevel)
    func selection()
    func notify(type: NotificationType)
}

public class HapticFeedback: NSObject {
    public static var shared: HapticFeedbackProtocol?
}
