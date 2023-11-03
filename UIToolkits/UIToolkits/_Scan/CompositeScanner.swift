//
//  CompositeScanner.swift
//  UIToolkits
//
//  Created by Qiang Huang on 6/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import AVFoundation
import UIKit

public class CompositeScanner: NSObject, ScannerProtocol {
    private var scanners = [ScannerProtocol]()

    public func install(scanner: ScannerProtocol) {
        scanners.append(scanner)
    }

    public func scan(buffer: CMSampleBuffer, completion: @escaping ScanCompletionBlock) {
        var completion: ScanCompletionBlock? = completion
        var count = 0

        for scanner in scanners {
            scanner.scan(buffer: buffer, completion: { [weak self] strings, error in
                if let self = self, let strings = strings {
                    // successful
                    if completion != nil {
                        completion?(strings, error)
                        completion = nil
                    } else {
                        count += 1
                        if count == self.scanners.count {
                            completion?(strings, error)
                        }
                    }
                }
            })
        }
    }

    public func scan(image: UIImage, completion: @escaping ScanCompletionBlock) {
        var completion: ScanCompletionBlock? = completion
        var count = 0

        for scanner in scanners {
            scanner.scan(image: image, completion: { [weak self] strings, error in
                if let self = self, let strings = strings {
                    // successful
                    if completion != nil {
                        completion?(strings, error)
                        completion = nil
                    } else {
                        count += 1
                        if count == self.scanners.count {
                            completion?(strings, error)
                        }
                    }
                }
            })
        }
    }
}
