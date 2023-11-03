//
//  CalendarPermission.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

@objc public class CalendarPermission: PrivacyPermission {
    private static var _shared: CalendarPermission?
    public static var shared: CalendarPermission {
        get {
            if _shared == nil {
                _shared = CalendarPermission()
            }
            return _shared!
        }
        set {
            _shared = newValue
        }
    }

    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if type(of: self)._shared == nil {
            type(of: self)._shared = super.awakeAfter(using: aDecoder) as? CalendarPermission
        }
        return type(of: self).shared
    }
}
