//
//  VidepProcessingCapture.swift
//  CameraParticles
//
//  Created by Qiang Huang on 6/12/20.
//

import AVFoundation
import Foundation

@objc open class QRCodeCapture: CameraCapture, AVCaptureMetadataOutputObjectsDelegate {
    @objc public dynamic var qrcode: String? {
        didSet {
            if qrcode != oldValue {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }

    override open func setupOutput() {
        let metadataOutput = AVCaptureMetadataOutput()
        output = metadataOutput
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first, let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
            qrcode = readableObject.stringValue
        }
    }
}
