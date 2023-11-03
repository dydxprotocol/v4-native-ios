//
//  VideoScanner.swift
//  CameraParticles
//
//  Created by Qiang Huang on 6/14/20.
//

import AVFoundation
import Foundation
import UIKit

@objc open class VideoScanner: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let context: CIContext = CIContext(options: nil)

    @objc open dynamic var scanning: Bool = false

    open func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if scanning {
            process(buffer: sampleBuffer)
        }
    }

    open func process(buffer: CMSampleBuffer) {
    }

    open func process(image: CIImage) {
    }

    public func ciImage(buffer: CMSampleBuffer?) -> CIImage? {
        if let buffer = buffer, let cvBuffer = CMSampleBufferGetImageBuffer(buffer) {
            return CIImage(cvPixelBuffer: cvBuffer)
        }
        return nil
    }

    public func cgImage(ciImage: CIImage?) -> CGImage? {
        if let ciImage = ciImage {
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        return nil
    }

    public func image(cgImage: CGImage?) -> UIImage? {
        if let cgImage = cgImage {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    public func image(ciImage: CIImage?) -> UIImage? {
        if let ciImage = ciImage {
            return UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
        }
        return nil
    }

    public func image(buffer: CMSampleBuffer?) -> UIImage? {
        return image(cgImage: cgImage(ciImage: ciImage(buffer: buffer)))
    }
}
