//
//  UploadService.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 8/13/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

@objc open class UploadService: NSObject, ProgressProtocol {
    public static var shared: UploadService?

    @objc open dynamic var uploadApi: UploadApi?

    @objc public dynamic var started: Bool = false

    @objc public dynamic var error: Error?

    @objc public dynamic var progress: Float = 0.0

    @objc public dynamic var text: String?

    open func upload() {
    }

    open func upload(object: Any?) {
    }
}
