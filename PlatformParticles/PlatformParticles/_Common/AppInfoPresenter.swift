//
//  AppInfoPresenter.swift
//  PlatformParticles
//
//  Created by Qiang Huang on 9/2/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import ParticlesKit
import UIToolkits

@objc public class AppInfoPresenter: ObjectPresenter {
    public var appInfo: AppInfo? {
        return model as? AppInfo
    }

    public override var model: ModelObjectProtocol? {
        didSet {
            if appInfo !== oldValue {
                update()
            }
        }
    }

    @IBOutlet var versionLabel: LabelProtocol? {
        didSet {
            if versionLabel !== oldValue {
                update()
            }
        }
    }

    private func update() {
        versionLabel?.text = appInfo?.version
    }
}
