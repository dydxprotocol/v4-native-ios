//
//  PointedRating.swift
//  Utilities
//
//  Created by Qiang Huang on 9/19/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

open class PointsRating: NSObject, RatingProtocol {
    public func add(points: Int) {
        self.points = self.points + points
    }

    private var pointsKey: String {
        return "\(String(describing: className)).points"
    }

    private var threshold: Int

    open var points: Int {
        get {
            return UserDefaults.standard.integer(forKey: pointsKey)
        }
        set {
            if newValue >= threshold {
                promptForRating()
                UserDefaults.standard.set(0, forKey: pointsKey)
            } else {
                UserDefaults.standard.set(newValue, forKey: pointsKey)
            }
        }
    }

    public init(threshold: Int) {
        self.threshold = threshold
        super.init()
    }

    open func promptForRating() {
    }
}
