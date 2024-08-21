//
//  ProgressPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 8/14/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Utilities

@objc open class ProgressPresenter: NSObject {
    @IBOutlet public var progressBar: UIProgressView?
    @IBOutlet public var titleLabel: UILabel?
    @IBOutlet public var detailLabel: UILabel?
    @IBOutlet public var imageView: UIImageView?
    @IBOutlet public var dismissButton: UIButton? {
        didSet {
            if dismissButton !== oldValue {
                oldValue?.removeTarget()
                dismissButton?.addTarget(self, action: #selector(dismiss(_:)))
            }
        }
    }

    @objc open dynamic var progress: ProgressProtocol? {
        didSet {
            changeObservation(from: oldValue, to: progress, keyPath: #keyPath(ProgressProtocol.started)) { [weak self] _, _, _, _ in
                self?.updateStarted()
            }
            changeObservation(from: oldValue, to: progress, keyPath: #keyPath(ProgressProtocol.progress)) { [weak self] _, _, _, _ in
                self?.updateProgress()
            }
            changeObservation(from: oldValue, to: progress, keyPath: #keyPath(ProgressProtocol.error)) { [weak self] _, _, _, _ in
                self?.updateError()
            }
            changeObservation(from: oldValue, to: progress, keyPath: #keyPath(ProgressProtocol.text)) { [weak self] _, _, _, _ in
                self?.updateText()
            }
        }
    }

    @IBAction open func dismiss(_ sender: Any?) {
    }

    open func updateStarted() {
        let started = progress?.started ?? false
        progressBar?.visible = started
        titleLabel?.visible = !started

        updateImage()
        updateText()
    }

    open func updateProgress() {
        progressBar?.setProgress(progress?.progress ?? 0, animated: true)
    }

    open func updateError() {
    }

    open func updateImage() {
    }

    open func updateText() {
    }
}
