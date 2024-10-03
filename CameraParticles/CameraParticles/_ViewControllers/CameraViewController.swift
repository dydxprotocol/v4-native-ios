//
//  CameraViewController.swift
//  CameraParticles
//
//  Created by Qiang Huang on 6/12/20.
//

import AVFoundation
import PlatformParticles
import RoutingKit
import UIToolkits
import Utilities

@objc open class CameraViewController: TrackingViewController {
    @IBOutlet open var cameraPermissionView: UIView?
    @IBOutlet open var cameraPermissionLabel: UILabel?

    @IBOutlet open var cameraPermissionButton: ButtonProtocol? {
        didSet {
            if cameraPermissionButton !== oldValue {
                oldValue?.removeTarget()
                cameraPermissionButton?.addTarget(self, action: #selector(permit(_:)))
            }
        }
    }

    open var cameraPermission: CameraPermission? {
        didSet {
            changeObservation(from: oldValue, to: cameraPermission, keyPath: #keyPath(CameraPermission.authorization)) { [weak self] _, _, _, _ in
                self?.updateCameraPermission()
            }
        }
    }

    open var cameraPermissionText: String? {
        return "You need to enable camera"
    }

    @IBOutlet open var cameraButton: ButtonProtocol? {
        didSet {
            if cameraButton !== oldValue {
                oldValue?.removeTarget()
                cameraButton?.addTarget(self, action: #selector(camera(_:)))
            }
        }
    }

    @IBOutlet open var flashButton: ButtonProtocol? {
        didSet {
            if flashButton !== oldValue {
                oldValue?.removeTarget()
                flashButton?.addTarget(self, action: #selector(light(_:)))
            }
        }
    }

    @IBOutlet open var exitButton: UIButton? {
        didSet {
            if exitButton !== oldValue {
                oldValue?.removeTarget()
                exitButton?.addTarget(self, action: #selector(dismiss(_:)))
            }
        }
    }

    @IBOutlet open var preview: UIView?
    @IBOutlet open var review: UIImageView?

    @objc open dynamic var capture: CameraCapture? {
        didSet {
            changeObservation(from: oldValue, to: capture, keyPath: #keyPath(CameraCapture.previewLayer)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.previewLayer = self.capture?.previewLayer
                }
            }
            changeObservation(from: oldValue, to: capture, keyPath: #keyPath(CameraCapture.light)) { [weak self] _, _, _, _ in
                if let self = self {
                    self.updateLight()
                }
            }
        }
    }

    open var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            if previewLayer !== oldValue {
                oldValue?.removeFromSuperlayer()
                if let preview = preview, let previewLayer = previewLayer {
                    previewLayer.frame = preview.bounds
                    preview.layer.insertSublayer(previewLayer, at: 0)
                }
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraPermission = CameraPermission.shared
        navigationController?.navigationBar.transparent = true
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        capture?.running = false
        capture = nil
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupCamera()
    }

    private func setupCamera() {
        if !UIDevice.current.isSimulator, cameraPermission?.authorization == .authorized {
            if let capture = createCapture() {
                capture.configure { [weak self] in
                    if let self = self {
                        self.setup(capture: capture)
                        self.capture = capture
                    }
                }
                capture.running = true
            }
        }
    }

    open func createCapture() -> CameraCapture? {
        return nil
    }

    open func setup(capture: CameraCapture) {
        capture.setup()
    }

    @IBAction open func camera(_ sender: Any?) {
        if let capture = capture {
            capture.front = !capture.front
        }
    }

    @IBAction open func light(_ sender: Any?) {
        if let capture = capture {
            capture.light = !capture.light
        }
    }

    @IBAction open func permit(_ sender: Any?) {
        Router.shared?.navigate(to: RoutingRequest(path: "/authorization/camera"), animated: true, completion: nil)
    }

    open func updateCameraPermission() {
        if let cameraPermission = cameraPermission {
            switch cameraPermission.authorization {
            case .authorized:
                setupCamera()
                cameraPermissionView?.visible = false

            default:
                cameraPermissionView?.bringToFront()
                exitButton?.bringToFront()
                cameraPermissionView?.visible = true
                cameraPermissionLabel?.text = cameraPermissionText
            }
        } else {
            cameraPermissionView?.visible = false
        }
    }

    open func updateLight() {
        if capture?.light ?? false {
            flashButton?.buttonImage = UIImage.named("flashlight.off.fill", bundles: Bundle.particles)
        } else {
            flashButton?.buttonImage = UIImage.named("flashlight.on.fill", bundles: Bundle.particles)
        }
    }
}
