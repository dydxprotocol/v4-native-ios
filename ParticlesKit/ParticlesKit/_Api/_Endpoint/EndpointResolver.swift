//
//  EndpointResolver.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 7/15/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol EndpointResolverProtocol {
    var host: String? { get }
    func path(for action: String) -> String?
}
