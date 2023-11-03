//
//  XibTableViewHeaderFooterView.swift
//  PlatformParticles
//
//  Created by John Huang on 3/8/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import ParticlesKit
import UIKit
import Utilities

@objc public class XibTableViewHeaderFooterView: UITableViewHeaderFooterView, ObjectPresenterProtocol {
    public var model: ModelObjectProtocol? {
        didSet {
            objectPresenterView?.model = model
        }
    }

    @objc public dynamic var xib: String? {
        didSet {
            if xib != oldValue {
                objectPresenterView = XibLoader.load(from: xib)
                #if DEBUG
                accessibilityIdentifier = "xib: \(xib ?? "")"
                #endif
            }
        }
    }

    @objc public dynamic var objectPresenterView: ObjectPresenterView? {
        didSet {
            if objectPresenterView !== oldValue {
                oldValue?.removeFromSuperview()
                if let objectPresenterView = objectPresenterView {
                    install(view: objectPresenterView, into: contentView)
                }
                backgroundColor = UIColor.clear
                contentView.backgroundColor = UIColor.clear
            }
        }
    }
}
