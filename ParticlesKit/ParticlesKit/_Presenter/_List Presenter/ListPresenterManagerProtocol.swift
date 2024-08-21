//
//  ListPresenterManagerProtocol.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/12/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

@objc public protocol ListPresenterManagerProtocol: NSObjectProtocol {
    var flat: Bool { get set }
    var flatConstraints: [NSLayoutConstraint]? { get set }
    var loadingPresenter: ListPresenter? { get set }
    var presenters: [ListPresenter]? { get set }
    var index: NSNumber? { get set }
    var current: ListPresenter? { get set }
}
