//
//  OCRService.swift
//  UIToolkits
//
//  Created by Qiang Huang on 9/17/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import AVFoundation
import UIKit

public typealias OCRCompletionHandler = (_ text: String?, _ error: Error?) -> Void

@objc public protocol OCRProtocol: NSObjectProtocol {
    func process(buffer: CMSampleBuffer, completion: @escaping OCRCompletionHandler)
    func process(image: UIImage, completion: @escaping OCRCompletionHandler)
}

public class OCRService {
    public static var shared: OCRProtocol?
}
