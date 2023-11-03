//
//  ScannerProtocol.swift
//  UIToolkits
//
//  Created by Qiang Huang on 6/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import AVFoundation
import UIKit

public typealias ScanCompletionBlock = (_ strings: [String: Set<String>]?, _ error: Error?) -> Void

public protocol ScannerProtocol: NSObjectProtocol {
    func scan(buffer: CMSampleBuffer, completion: @escaping ScanCompletionBlock)
    func scan(image: UIImage, completion: @escaping ScanCompletionBlock)
}
