//
//  FilteredListInteractorProtocol.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 12/19/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import Foundation

public protocol FilteredListInteractorProtocol: NSObjectProtocol {
    var onlyShowLiked: Bool { get set }
    var liked: LikedObjectsProtocol? { get set }
    var filters: FilterEntity? { get set }
    var filterText: String? { get set }
    var data: [ModelObjectProtocol]? { get }
}

public protocol FilteredObjectProtocol: NSObjectProtocol {
    func filter(text: String?) -> Bool
}
