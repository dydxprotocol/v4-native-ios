//
//  RatingService.swift
//  Utilities
//
//  Created by Qiang Huang on 9/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

public protocol RatingProtocol: NSObjectProtocol {
    func add(points: Int)
}

public class RatingService {
    public static var shared: RatingProtocol?
}
