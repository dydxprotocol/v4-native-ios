//
//  ImageUploaderProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 11/28/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import CoreLocation
import Foundation

public typealias UploadCompletion = (_: String?, _: Error?) -> Void

@objc public protocol ImageUploaderProtocol: NSObjectProtocol {
    @objc var uploading: Bool { get set }
    @objc var progress: Float { get set }

    func upload(image: UIImage, location: CLLocation?, completion: UploadCompletion?)
    func upload(file: String, location: CLLocation?, completion: UploadCompletion?)
}
