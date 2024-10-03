//
//  OCRVideoProcessingViewController.swift
//  CameraParticles
//
//  Created by Qiang Huang on 6/15/20.
//

import AVFoundation
import Foundation
import RoutingKit
import UIToolkits
import Utilities

@objc open class TextVideoProcessingViewController: VideoProcessingViewController, VideoTextScannerDelegate {
    @IBInspectable open var offColor: UIColor?
    @IBInspectable open var onColor: UIColor?
    @IBOutlet open var viewFinder: OverlayView?
    @IBOutlet open var markers: [UIView]?

    var overlayColor: UIColor? {
        didSet {
            if overlayColor !== oldValue {
                viewFinder?.overlayColor = overlayColor
                if let markers = markers {
                    for marker in markers {
                        marker.backgroundColor = overlayColor
                    }
                }
            }
        }
    }

    @IBInspectable open var path: String?

    @IBInspectable open var scannerType: String? {
        didSet {
            if scannerType != oldValue {
            }
        }
    }

    open var data: [String: Set<String>] = [:]

    open var textScanner: VideoTextScanner? {
        return videoProcessor as? VideoTextScanner
    }

    override open var videoProcessor: VideoScanner? {
        didSet {
            if videoProcessor !== oldValue {
                (capture as? VideoProcessingCapture)?.videoProcessing = videoProcessor
                textScanner?.delegate = self
            }
        }
    }

    override open var capture: CameraCapture? {
        didSet {
            if capture !== oldValue {
                (capture as? VideoProcessingCapture)?.videoProcessing = videoProcessor
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScanningStatus()
    }

    override open func updateTo(scanningStatus: EScanningStatus) {
        super.updateTo(scanningStatus: scanningStatus)

        switch scanningStatus {
        case .idle:
            break

        case .scanning:
            data = [:]
            play(sound: soundScanning())
            case .processing:
            play(sound: sound(types: data))
            complete(data: data)

        default:
            break
        }
        updateScanningStatus()
    }

    open func updateScanningStatus() {
        overlayColor = color(scanningStatus: scanningStatus)
    }

    open func color(scanningStatus: EScanningStatus) -> UIColor {
        switch scanningStatus {
        case .scanning:
            return (onColor ?? UIColor(white: 0.0, alpha: 0.33))

        default:
            return (offColor ?? UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.33))
        }
    }

    override open func createCapture() -> CameraCapture? {
        let scanner = VideoTextScanner()
        scanner.scanner = Scanners.shared.scanner(type: scannerType ?? "QRCode")
        videoProcessor = scanner
        let capture = VideoProcessingCapture()
        return capture
    }

    public func receiving(_ scanner: VideoTextScanner, buffer: CMSampleBuffer) {
    }

    open func scanner(_ scanner: VideoTextScanner, buffer: CMSampleBuffer, strings: [String: Set<String>]) {
        if scanningStatus == .scanning {
            if add(strings: strings) {
                dataAdded()
            }
        }
    }

    open func dataAdded() {
        scanningStatus = .processing
    }

    public func add(strings: [String: Set<String>]) -> Bool {
        var hasNew = false
        var scannedTypes: Set<String> = []
        for type in strings.keys {
            if let value = strings[type] {
                var set: Set<String> = data[type] ?? []
                for each in value {
                    if !set.contains(each) {
                        set.insert(each)
                        scannedTypes.insert(type)
                        hasNew = true
                    }
                }
                data[type] = set
            }
        }
        return hasNew
    }

    open func shouldFinish() -> Bool {
        return false
    }

    open func play(sound: UInt32) {
        if sound != 0 {
            AudioServicesPlayAlertSound(SystemSoundID(sound))
        }
    }

    open func soundScanning() -> UInt32 {
        return 0
    }

    open func sound(types: [String: Set<String>]) -> UInt32 {
        return 0
    }

    open func complete(data: [String: Set<String>]) {
    }

    override open func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == path || path == nil {
            scannerType = request?.params?["barcode"] as? String
            return true
        }
        return false
    }
}
