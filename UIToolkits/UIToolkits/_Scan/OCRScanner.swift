//
//  OCRScanner.swift
//  UIToolkits
//
//  Created by Qiang Huang on 7/11/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import AVFoundation

public class OCRScanner: NSObject, ScannerProtocol {
    public func scan(buffer: CMSampleBuffer, completion: @escaping ScanCompletionBlock) {
        completion(nil, nil)
    }

    public func scan(image: UIImage, completion: @escaping ScanCompletionBlock) {
        if let ocr = OCRService.shared {
            ocr.process(image: image) { string, error in
                if let string = string {
                    completion(["text": [string]], error)
                } else {
                    completion(nil, error)
                }
            }
        } else {
            completion(nil, nil)
        }
    }
}
