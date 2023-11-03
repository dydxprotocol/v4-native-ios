//
//  QRCodeViewController.swift
//  QRCodeViewController
//
//  Created by Qiang Huang on 9/2/21.
//  Copyright © 2021 dYdX Trading, Inc. All rights reserved.
//

@objc open class QRCodeViewController: CameraViewController {
    @Published public var qrcode: String?
    
    override open var capture: CameraCapture? {
        didSet {
            changeObservation(from: oldValue, to: qrcodeCapture, keyPath: #keyPath(QRCodeCapture.qrcode)) { [weak self] _, _, _, _ in
                self?.process(qrcode: self?.qrcodeCapture?.qrcode)
            }
        }
    }

    public var qrcodeCapture: QRCodeCapture? {
        return capture as? QRCodeCapture
    }

    override open func createCapture() -> CameraCapture? {
        if let capture = capture {
            return capture
        } else {
            return QRCodeCapture()
        }
    }

    open func process(qrcode: String?) {
        self.qrcode = qrcode
    }
}
