//
//  TimeIntervale+String.swift
//  Utilities
//
//  Created by Qiang Huang on 5/27/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

extension TimeInterval {
    var text: String? {
        let ms = Int(truncatingRemainder(dividingBy: 1) * 1000)

        return String(format: "\(shortText).%0.3d", ms)
    }

    var shortText: String {
        let time = NSInteger(self)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        if hours > 0 {
            return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
        } else {
            return String(format: "%0.2d:%0.2d", minutes, seconds)
        }
    }
}
