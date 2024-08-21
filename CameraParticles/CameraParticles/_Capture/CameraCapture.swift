//
//  CameraCapture.swift
//  CameraParticles
//
//  Created by Qiang Huang on 6/12/20.
//

import AVFoundation
import Foundation

@objc open class CameraCapture: NSObject {
    public var defaultFront: Bool = false
    public var defaultFlash: Bool = false

    private var lock: Int = 0 {
        didSet {
            if lock != oldValue {
                if oldValue == 0 {
                    session.beginConfiguration()
                } else if lock == 0 {
                    session.commitConfiguration()
                }
            }
        }
    }

    @objc open dynamic var running: Bool = false {
        didSet {
            if running != oldValue {
                if running {
                    DispatchQueue.global().async { [weak self] in
                        self?.session.startRunning()
                    }
                } else {
                    DispatchQueue.global().async { [weak self] in
                        self?.session.stopRunning()
                    }
                }
            }
        }
    }

    lazy var frontTag: String = {
        "\(className()).front"
    }()

    lazy var flashTag: String = {
        "\(className()).flash"
    }()

    @objc open dynamic var front: Bool {
        get {
            return parser.asBoolean(UserDefaults.standard.string(forKey: frontTag))?.boolValue ?? defaultFlash
        }
        set {
            if front != newValue {
                UserDefaults.standard.set(newValue ? "1" : "0", forKey: frontTag)
                setupCamera()
            }
        }
    }

    @objc open dynamic var light: Bool {
        get {
            return parser.asBoolean(UserDefaults.standard.string(forKey: flashTag))?.boolValue ?? defaultFlash
        }
        set {
            if light != newValue {
                UserDefaults.standard.set(newValue ? "1" : "0", forKey: flashTag)
                setupLight()
            }
        }
    }

    @objc open dynamic var hasAudio: Bool = false {
        didSet {
            if hasAudio != oldValue {
                audio = hasAudio ? AVCaptureDevice.default(for: .audio) : nil
            }
        }
    }

    @objc open dynamic var camera: AVCaptureDevice? {
        didSet {
            if camera !== oldValue {
                if let camera = camera {
                    do {
                        videoInput = try AVCaptureDeviceInput(device: camera)
                    } catch _ {
                    }
                    DispatchQueue.main.async {[weak self] in
                        self?.setupLight()
                    }
                } else {
                    videoInput = nil
                }
            }
        }
    }

    @objc open dynamic var audio: AVCaptureDevice? {
        didSet {
            if audio !== oldValue {
                if let audio = audio {
                    do {
                        audioInput = try AVCaptureDeviceInput(device: audio)
                    } catch _ {
                    }
                } else {
                    audioInput = nil
                }
            }
        }
    }

    @objc open dynamic var videoInput: AVCaptureDeviceInput? {
        didSet {
            if videoInput !== oldValue {
                configure { [weak self] in
                    if let self = self {
                        if let oldInput = oldValue {
                            session.removeInput(oldInput)
                        }
                        if let videoInput = self.videoInput, session.canAddInput(videoInput) {
                            session.addInput(videoInput)
                            if previewLayer == nil {
                                self.session.sessionPreset = .hd1920x1080
                                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                                previewLayer.videoGravity = .resizeAspectFill
                                previewLayer.connection?.videoOrientation = .portrait
                                self.previewLayer = previewLayer
                            }
                        }
                    }
                }
            }
        }
    }

    @objc open dynamic var audioInput: AVCaptureDeviceInput? {
        didSet {
            if audioInput !== oldValue {
                configure { [weak self] in
                    if let self = self {
                        if let oldInput = oldValue {
                            session.removeInput(oldInput)
                        }
                        if let audioInput = self.audioInput, session.canAddInput(audioInput) {
                            session.addInput(audioInput)
                        }
                    }
                }
            }
        }
    }

    @objc open dynamic var output: AVCaptureOutput? {
        didSet {
            if output !== oldValue {
                configure { [weak self] in
                    if let self = self {
                        if let oldOutput = oldValue {
                            session.removeOutput(oldOutput)
                        }
                        if let output = self.output, session.canAddOutput(output) {
                            session.addOutput(output)
                        }
                        if let connection = output?.connection(with: .video) {
                            connection.videoOrientation = .portrait
                        }
                    }
                }
            }
        }
    }

    @objc open dynamic var session: AVCaptureSession = AVCaptureSession()

    @objc open dynamic var previewLayer: AVCaptureVideoPreviewLayer?

    open func setup() {
        configure { [weak self] in
            if let self = self {
                self.setupInput()
                self.setupOutput()
            }
        }
    }

    open func setupInput() {
        setupCamera()
    }

    open func setupCamera() {
        camera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: front ? .front : .back) ?? AVCaptureDevice.default(for: .video)
    }

    open func setupLight() {
        if let camera = camera, camera.isTorchAvailable {
            do {
                try camera.lockForConfiguration()
                if light {
                    camera.torchMode = .on
                    try camera.setTorchModeOn(level: 0.9)
                } else {
                    camera.torchMode = .off
                }
            } catch {
            }
        }
    }

    open func setupOutput() {
    }

    open func configure(doing: () -> Void) {
        lock = lock + 1
        doing()
        lock = lock - 1
    }
}
