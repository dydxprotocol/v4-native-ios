//
//  AppInfo.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 8/28/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

@objc public final class AppInfo: NSObject, ModelObjectProtocol, SingletonProtocol {
    public static var shared: AppInfo = AppInfo()

    @objc public dynamic var name: String?
    @objc public dynamic var version: String?

    public var fullName: String? {
        if let name = name {
            if let version = version {
                return "\(name) v\(version)"
            } else {
                return name
            }
        } else {
            return nil
        }
    }

    override public init() {
        super.init()

        name = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? (Bundle.main.infoDictionary?["CFBundleName"] as? String)

        if let version = Bundle.main.version {
            if let build = Bundle.main.build {
                self.version = "\(version).\(build)"
            } else {
                self.version = "\(version)"
            }
        }
    }
}
