//
//  GridPresenterManagerProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 1/16/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

@objc public protocol GridPresenterManagerProtocol: NSObjectProtocol {
    var loadingPresenter: GridPresenter? { get set }
    var presenters: [GridPresenter]? { get set }
    var index: NSNumber? { get set }
    var current: GridPresenter? { get set }
}
