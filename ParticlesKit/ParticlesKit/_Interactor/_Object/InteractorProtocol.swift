//
//  ObjectInteractor.swift
//  InteractorLib
//
//  Created by Qiang Huang on 10/10/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import RoutingKit

@objc public protocol ActionProtocol: ModelObjectProtocol {
    @objc var title: String? { get }
    @objc var subtitle: String? { get }
    @objc var detail: String? { get }
    @objc var image: String? { get }
    @objc var routing: RoutingRequest? { get }
    @objc var detailRouting: RoutingRequest? { get }
}

@objc public protocol InteractorProtocol: ModelObjectProtocol {
    @objc var entity: ModelObjectProtocol? { get set }
}

@objc public protocol LoadingInteractorProtocol: InteractorProtocol {
    var objectKey: String? { get set }
}
