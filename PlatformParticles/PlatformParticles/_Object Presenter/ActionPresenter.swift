//
//  ActionPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 2/10/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits
import Utilities

public class ActionPresenter: ObjectPresenter {
    open override var model: ModelObjectProtocol? {
        didSet {
            let dictionaryEntity = action as? DictionaryEntity
            changeObservation(from: oldValue, to: dictionaryEntity, keyPath: #keyPath(DictionaryEntity.data)) { [weak self] _, _, _, _ in
                self?.update()
            }
        }
    }

    public var action: ActionProtocol? {
        return model as? ActionProtocol
    }

    @IBOutlet var titleLabel: LabelProtocol?
    @IBOutlet var subtitleLabel: LabelProtocol?
    @IBOutlet var imageView: ImageViewProtocol?
    @IBOutlet var detailLabel: LabelProtocol?
    @IBOutlet var detailButton: ButtonProtocol? {
        didSet {
            oldValue?.removeTarget()
            detailButton?.addTarget(self, action: #selector(detail(_:)))
        }
    }

    @IBAction func detail(_ sender: Any?) {
    }

    private func update() {
        titleLabel?.text = action?.title?.localized
        subtitleLabel?.text = action?.subtitle?.localized
        if let image = action?.image {
            imageView?.image = UIImage(named: image)
        } else {
            imageView?.image = nil
        }
        detailButton?.buttonTitle = action?.detail?.localized
        detailLabel?.text = action?.detail?.localized
        if let _ = action?.detailRouting {
            detailLabel?.visible = false
            detailButton?.visible = true
        } else {
            detailButton?.visible = false
            detailLabel?.visible = true
        }
    }
}
