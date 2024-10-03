//
//  VideoTextScanner.swift
//  CameraParticles
//
//  Created by Qiang Huang on 6/14/20.
//

import AVFoundation
import CoreImage
import UIToolkits
import Utilities

@objc public protocol VideoTextScannerDelegate {
    func receiving(_ scanner: VideoTextScanner, buffer: CMSampleBuffer)
    func scanner(_ scanner: VideoTextScanner, buffer: CMSampleBuffer, strings: [String: Set<String>])
}

@objc open class VideoTextScanner: VideoScanner {
    public weak var delegate: VideoTextScannerDelegate?
    public var scanner: ScannerProtocol?

    internal var scanDebouncer: Debouncer = {
        let debouncer = Debouncer()
        debouncer.fifo = true
        return debouncer
    }()

    open override func process(buffer: CMSampleBuffer) {
        if let _ = delegate, let _ = scanner {
            if let handler = scanDebouncer.debounce() {
                handler.run({ [weak self] in
                    if let self = self {
                        self.delegate?.receiving(self, buffer: buffer)
                        self.scan(buffer: buffer) {[weak self] strings, _ in
                            if let self = self, let strings = strings {
                                self.delegate?.scanner(self, buffer: buffer, strings: strings)
                            }
                        }
                        self.scanDebouncer.current = nil
                    }
                }, delay: 0)
            }
        }
    }

    open func scan(buffer: CMSampleBuffer, completion: @escaping ScanCompletionBlock) {
        scanner?.scan(buffer: buffer, completion: { [weak self] strings, error in
            if let strings = self?.postProcess(strings: strings) {
                completion(strings, error)
            }
        })
    }

    open func postProcess(strings: [String: Set<String>]?) -> [String: Set<String>]? {
        return strings
    }
}
