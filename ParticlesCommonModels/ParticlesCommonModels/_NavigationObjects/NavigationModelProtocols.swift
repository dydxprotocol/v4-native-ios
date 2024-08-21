//
//  CommonModelProtocols.swift
//  ParticlesCommonModels
//
//  Created by Qiang Huang on 1/30/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit

@objc public protocol NavigationModelProtocol: ModelObjectProtocol {
    @objc var title: String? { get }
    @objc var subtitle: String? { get }
    @objc var text: String? { get }
    @objc var subtext: String? { get }
    @objc var color: String? { get }
    @objc var icon: URL? { get }
    @objc var image: URL? { get }
    @objc var link: URL? { get }
    @objc var tag: String? { get }

    @objc var children: [NavigationModelProtocol]? { get }
    @objc var actions: [NavigationModelProtocol]? { get }
}
